include: "/views/base_events.view.lkml"
view: events {
  extends: [base_events]
  sql_table_name: `miles-partnership-ga4.analytics_{% parameter profile %}.events_*` ;;

  parameter: profile {
    type: unquoted
    allowed_value: {
      label: "occroadhouse"
      value: "269520886"
    }
    allowed_value: {
      label: "alaskatia"
      value: "347778234"
    }
  }

  parameter: audience_selector {
    description: "Use to set 'Audience Trait' field to dynamically choose a user cohort."
    type: string
    allowed_value: { value: "Device" }
    allowed_value: { value: "Operating System" }
    allowed_value: { value: "Browser" }
    allowed_value: { value: "Country" }
    allowed_value: { value: "Continent" }
    allowed_value: { value: "Metro" }
    allowed_value: { value: "Language" }
    allowed_value: { value: "Channel" }
    allowed_value: { value: "Medium" }
    allowed_value: { value: "Source" }
    default_value: "Source"
  }

  dimension: audience_trait {
    description: "Dynamic cohort field based on value set in 'Audience Selector' filter."
    type: string
    sql: CASE
              WHEN {% parameter audience_selector %} = 'Channel' THEN ${attribution_channel}
              WHEN {% parameter audience_selector %} = 'Medium' THEN ${traffic_source__medium}
              WHEN {% parameter audience_selector %} = 'Source' THEN ${traffic_source__source}
              WHEN {% parameter audience_selector %} = 'Device' THEN ${device__category}
              WHEN {% parameter audience_selector %} = 'Browser' THEN ${device__web_info__browser}
              WHEN {% parameter audience_selector %} = 'Metro' THEN ${geo__metro}
              WHEN {% parameter audience_selector %} = 'Country' THEN ${geo__country}
              WHEN {% parameter audience_selector %} = 'Continent' THEN ${geo__continent}
              WHEN {% parameter audience_selector %} = 'Language' THEN ${device__language}
              WHEN {% parameter audience_selector %} = 'Operating System' THEN ${device__operating_system}
        END;;
  }

  dimension: event_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: concat(${_event_raw}, ${unique_session_id}, ${event_name}) ;;
  }

  dimension: ga_session_number {
    label: "GA Session Number"
    view_label: "Sessions"
    type: number
    sql: (SELECT value.int_value FROM ${event_params} where key='ga_session_number') ;;
  }

  dimension: page_location {
    type: string
    hidden: yes
    sql: (SELECT value.string_value FROM ${event_params} where key='page_location') ;;
  }

  dimension: page {
    group_label: "Page"
    type: string
    sql: coalesce(regexp_extract(${page_location},r"(?:.*?[\.][^\/]*)([\/][^\?#]+)"),'/') ;;
    }

  measure: count_unique_page_views {
    group_label: "Page"
    label: "Unique Pageviews"
    description: "Unique Pageviews are the number of sessions during which the specified page was viewed at least once. A unique pageview is counted for each page URL + page title combination."
    type: count_distinct
    sql: CONCAT(${ga_session_id}, ${page}, ${page_title}) ;;
    filters: [event_name: "page_view"]
  }

  measure: count_of_page_views {
    group_label: "Page"
    label: "Pageviews"
    type: count
    filters: [event_name: "page_view"]
  }

  dimension: ga_session_id {
    label: "GA Session ID"
    view_label: "Sessions"
    type: string
    sql: CAST((SELECT value.int_value FROM ${event_params} where key='ga_session_id') AS STRING) ;;
  }

  dimension: unique_session_id {
    type: string
    sql: concat(${event_date}, '-', ${ga_session_id}, '-', ${ga_session_number}, '-' ${user_pseudo_id}) ;;
  }

  dimension: page_title {
    group_label: "Page"
    type: string
    sql: (SELECT value.string_value FROM ${event_params} where key='page_title') ;;
  }

  dimension: source {
    hidden: yes
    type: string
    sql: (SELECT value.string_value FROM ${event_params} where key='source') ;;
  }

  dimension: campaign {
    type: string
    sql: (SELECT value.string_value FROM ${event_params} where key='campaign') ;;
  }

  dimension: is_engaged_session_event {
    hidden: no
    type: yesno
    sql: (SELECT value.int_value FROM ${event_params} where key='engaged_session_event')=1 ;;
  }

  dimension: is_session_engaged {
    hidden: no
    type: yesno
    sql: (SELECT value.string_value FROM ${event_params} where key='session_engaged')="1" ;;
  }

  dimension_group: event {
    type: time
    timeframes: [date, week, day_of_week, day_of_month, month, month_name, year]
    sql: TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'\d\d\d\d\d\d\d\d'))) ;;
  }

  dimension_group: _event {
    label: "Event"
    timeframes: [raw,time,hour,minute]
    type: time
    sql: TIMESTAMP_MICROS(${TABLE}.event_timestamp) ;;
  }

  dimension_group: today {
    type: time
    hidden: yes
    sql: current_timestamp() ;;
    timeframes: [raw, day_of_month, month]
  }

  dimension_group: one_month_ago {
    type: time
    hidden: yes
    sql: DATE_SUB(current_date(), INTERVAL 1 MONTH) ;;
    timeframes: [month]
  }

  dimension: event_time_period {
    group_label: "Event Date"
    label: "Period"
    sql:
      case
        when ${event_month} = ${today_month} then "This Month"
        when ${event_month} = ${one_month_ago_month} and ${event_day_of_month} <= ${today_day_of_month} then "Last Month to Date"
      end
    ;;
  }

  dimension: attribution_channel {
    group_label: "Traffic Source"
    label: "Channel"
    description: "Default Channel Grouping as defined in https://support.google.com/analytics/answer/9756891?hl=en"
    ## UPDATED: 2022-07-27
    sql:
    case
      -- DIRECT
      when ${traffic_source__source} = '(direct)'
       and (${traffic_source__medium} = '(none)' or ${traffic_source__medium} = '(not set)')
        then 'Direct'

      -- CROSS-NETWORK
      when ${campaign} like '%cross-network%'
      then 'Cross-Network'

      -- PAID SHOPPING
      when (${traffic_source__source} IN (
      'Google Shopping','IGShopping','aax-us-east.amazon-adsystem.com','aax.amazon-adsystem.com','alibaba',
      'alibaba.com','amazon','amazon.co.uk','amazon.com','apps.shopify.com','checkout.shopify.com','checkout.stripe.com',
      'cr.shopping.naver.com','cr2.shopping.naver.com','ebay','ebay.co.uk','ebay.com','ebay.com.au','ebay.de',
      'etsy','etsy.com','m.alibaba.com','m.shopping.naver.com','mercadolibre','mercadolibre.com','mercadolibre.com.ar',
      'mercadolibre.com.mx','message.alibaba.com','msearch.shopping.naver.com','nl.shopping.net','no.shopping.net','offer.alibaba.com',
      'one.walmart.com','order.shopping.yahoo.co.jp','partners.shopify.com','s3.amazonaws.com','se.shopping.net','shop.app','shopify',
      'shopify.com','shopping.naver.com','shopping.yahoo.co.jp','shopping.yahoo.com','shopzilla','shopzilla.com','simplycodes.com',
      'store.shopping.yahoo.co.jp','stripe','stripe.com','uk.shopping.net','walmart','walmart.com'
      )
      or REGEXP_CONTAINS(${campaign}, r"^(.*(([^a-df-z]|^)shop|shopping).*)$") )
      and REGEXP_CONTAINS(${traffic_source__medium}, r"^(.*cp.*|ppc|paid.*)$")
      then 'Paid Shopping'

      -- PAID SEARCH
      when ${traffic_source__source} IN (
      '360.cn','alice','aol','ar.search.yahoo.com','ask','at.search.yahoo.com','au.search.yahoo.com','auone','avg',
      'babylon','baidu','biglobe','biglobe.co.jp','biglobe.ne.jp','bing','br.search.yahoo.com','ca.search.yahoo.com',
      'centrum.cz','ch.search.yahoo.com','cl.search.yahoo.com','cn.bing.com','cnn','co.search.yahoo.com','comcast',
      'conduit','cse.google.com','daum','daum.net','de.search.yahoo.com','dk.search.yahoo.com','dogpile','dogpile.com',
      'duckduckgo','ecosia.org','email.seznam.cz','eniro','es.search.yahoo.com','espanol.search.yahoo.com','exalead.com',
      'excite.com','fi.search.yahoo.com','firmy.cz','fr.search.yahoo.com','globo','go.mail.ru','google','google-play',
      'google.com','googlemybusiness','hk.search.yahoo.com','id.search.yahoo.com','in.search.yahoo.com','incredimail',
      'it.search.yahoo.com','kvasir','lite.qwant.com','lycos','m.baidu.com','m.naver.com','m.search.naver.com','m.sogou.com',
      'mail.google.com','mail.rambler.ru','mail.yandex.ru','malaysia.search.yahoo.com','msn','msn.com','mx.search.yahoo.com',
      'najdi','naver','naver.com','news.google.com','nl.search.yahoo.com','no.search.yahoo.com','ntp.msn.com','nz.search.yahoo.com',
      'onet','onet.pl','pe.search.yahoo.com','ph.search.yahoo.com','pl.search.yahoo.com','qwant','qwant.com','rakuten','rakuten.co.jp',
      'rambler','rambler.ru','se.search.yahoo.com','search-results','search.aol.co.uk','search.aol.com','search.google.com',
      'search.smt.docomo.ne.jp','search.ukr.net','secureurl.ukr.net','seznam','seznam.cz','sg.search.yahoo.com','so.com','sogou',
      'sogou.com','sp-web.search.auone.jp','startsiden','startsiden.no','suche.aol.de','terra','th.search.yahoo.com',
      'tr.search.yahoo.com','tut.by','tw.search.yahoo.com','uk.search.yahoo.com','ukr','us.search.yahoo.com','virgilio',
      'vn.search.yahoo.com','wap.sogou.com','webmaster.yandex.ru','websearch.rakuten.co.jp','yahoo','yahoo.co.jp','yahoo.com',
      'yandex','yandex.by','yandex.com','yandex.com.tr','yandex.fr','yandex.kz','yandex.ru','yandex.ua','yandex.uz','zen.yandex.ru'
      )
      and REGEXP_CONTAINS(${traffic_source__medium}, r"^(.*cp.*|ppc|paid.*)$")
      then 'Paid Search'

      -- PAID SOCIAL
      when ${traffic_source__source} IN (
      '43things','43things.com','51.com','5ch.net','Hatena','ImageShack','academia.edu','activerain','activerain.com','activeworlds','activeworlds.com','addthis','addthis.com','airg.ca','allnurses.com','allrecipes.com','alumniclass','alumniclass.com','ameba.jp',
      'ameblo.jp','americantowns','americantowns.com','amp.reddit.com','ancestry.com','anobii','anobii.com','answerbag','answerbag.com','answers.yahoo.com','aolanswers','aolanswers.com','apps.facebook.com','ar.pinterest.com','artstation.com','askubuntu',
      'askubuntu.com','asmallworld.com','athlinks','athlinks.com','away.vk.com','awe.sm','b.hatena.ne.jp','baby-gaga','baby-gaga.com','babyblog.ru','badoo','badoo.com','bebo','bebo.com','beforeitsnews','beforeitsnews.com','bharatstudent','bharatstudent.com',
      'biip.no','biswap.org','bit.ly','blackcareernetwork.com','blackplanet','blackplanet.com','blip.fm','blog.com','blog.feedspot.com','blog.goo.ne.jp','blog.naver.com','blog.yahoo.co.jp','blogg.no','bloggang.com','blogger','blogger.com','blogher','blogher.com',
      'bloglines','bloglines.com','blogs.com','blogsome','blogsome.com','blogspot','blogspot.com','blogster','blogster.com','blurtit','blurtit.com','bookmarks.yahoo.co.jp','bookmarks.yahoo.com','br.pinterest.com','brightkite','brightkite.com','brizzly','brizzly.com',
      'business.facebook.com','buzzfeed','buzzfeed.com','buzznet','buzznet.com','cafe.naver.com','cafemom','cafemom.com','camospace','camospace.com','canalblog.com','care.com','care2','care2.com','caringbridge.org','catster','catster.com','cbnt.io','cellufun',
      'cellufun.com','centerblog.net','chat.zalo.me','chegg.com','chicagonow','chicagonow.com','chiebukuro.yahoo.co.jp','classmates','classmates.com','classquest','classquest.com','co.pinterest.com','cocolog-nifty','cocolog-nifty.com','copainsdavant.linternaute.com',
      'couchsurfing.org','cozycot','cozycot.com','cross.tv','crunchyroll','crunchyroll.com','cyworld','cyworld.com','cz.pinterest.com','d.hatena.ne.jp','dailystrength.org','deluxe.com','deviantart','deviantart.com','dianping','dianping.com','digg','digg.com','diigo',
      'diigo.com','discover.hubpages.com','disqus','disqus.com','dogster','dogster.com','dol2day','dol2day.com','doostang','doostang.com','dopplr','dopplr.com','douban','douban.com','draft.blogger.com','draugiem.lv','drugs-forum','drugs-forum.com','dzone','dzone.com',
      'edublogs.org','elftown','elftown.com','epicurious.com','everforo.com','exblog.jp','extole','extole.com','facebook','facebook.com','faceparty','faceparty.com','fandom.com','fanpop','fanpop.com','fark','fark.com','fb','fb.me','fc2','fc2.com','feedspot','feministing',
      'feministing.com','filmaffinity','filmaffinity.com','flickr','flickr.com','flipboard','flipboard.com','folkdirect','folkdirect.com','foodservice','foodservice.com','forums.androidcentral.com','forums.crackberry.com','forums.imore.com','forums.nexopia.com',
      'forums.webosnation.com','forums.wpcentral.com','fotki','fotki.com','fotolog','fotolog.com','foursquare','foursquare.com','free.facebook.com','friendfeed','friendfeed.com','fruehstueckstreff.org','fubar','fubar.com','gaiaonline','gaiaonline.com',
      'gamerdna','gamerdna.com','gather.com','geni.com','getpocket.com','glassboard','glassboard.com','glassdoor','glassdoor.com','godtube','godtube.com','goldenline.pl','goldstar','goldstar.com','goo.gl','gooblog','goodreads','goodreads.com','google+',
      'googlegroups.com','googleplus','govloop','govloop.com','gowalla','gowalla.com','gree.jp','groups.google.com','gulli.com','gutefrage.net','habbo','habbo.com','hi5','hi5.com','hootsuite','hootsuite.com','houzz','houzz.com','hoverspot','hoverspot.com',
      'hr.com','hu.pinterest.com','hubculture','hubculture.com','hubpages.com','hyves.net','hyves.nl','ibibo','ibibo.com','id.pinterest.com','identi.ca','ig','imageshack.com','imageshack.us','imvu','imvu.com','in.pinterest.com','insanejournal','insanejournal.com','instagram',
      'instagram.com','instapaper','instapaper.com','internations.org','interpals.net','intherooms','intherooms.com','irc-galleria.net','is.gd','italki','italki.com','jammerdirect','jammerdirect.com','jappy.com','jappy.de','kaboodle.com','kakao','kakao.com','kakaocorp.com',
      'kaneva','kaneva.com','kin.naver.com','l.facebook.com','l.instagram.com','l.messenger.com','last.fm','librarything','librarything.com','lifestream.aol.com','line','line.me','linkedin','linkedin.com','listal','listal.com','listography','listography.com','livedoor.com',
      'livedoorblog','livejournal','livejournal.com','lm.facebook.com','lnkd.in','m.blog.naver.com','m.cafe.naver.com','m.facebook.com','m.kin.naver.com','m.vk.com','m.yelp.com','mbga.jp','medium.com','meetin.org','meetup','meetup.com','meinvz.net','meneame.net','menuism.com',
      'messages.google.com','messages.yahoo.co.jp','messenger','messenger.com','mix.com','mixi.jp','mobile.facebook.com','mocospace','mocospace.com','mouthshut','mouthshut.com','movabletype','movabletype.com','mubi','mubi.com','my.opera.com','myanimelist.net','myheritage','myheritage.com',
      'mylife','mylife.com','mymodernmet','mymodernmet.com','myspace','myspace.com','netvibes','netvibes.com','news.ycombinator.com','newsshowcase','nexopia','ngopost.org','niconico','nicovideo.jp','nightlifelink','nightlifelink.com','ning','ning.com','nl.pinterest.com','odnoklassniki.ru',
      'odnoklassniki.ua','okwave.jp','old.reddit.com','oneworldgroup.org','onstartups','onstartups.com','opendiary','opendiary.com','oshiete.goo.ne.jp','out.reddit.com','over-blog.com','overblog.com','paper.li','partyflock.nl','photobucket','photobucket.com','pinboard','pinboard.in','pingsta',
      'pingsta.com','pinterest','pinterest.at','pinterest.ca','pinterest.ch','pinterest.cl','pinterest.co.kr','pinterest.co.uk','pinterest.com','pinterest.com.au','pinterest.com.mx','pinterest.de','pinterest.es','pinterest.fr','pinterest.it','pinterest.jp','pinterest.nz','pinterest.ph',
      'pinterest.pt','pinterest.ru','pinterest.se','pixiv.net','pl.pinterest.com','playahead.se','plurk','plurk.com','plus.google.com','plus.url.google.com','pocket.co','posterous','posterous.com','pro.homeadvisor.com','pulse.yahoo.com','qapacity','qapacity.com','quechup',
      'quechup.com','quora','quora.com','qzone.qq.com','ravelry','ravelry.com','reddit','reddit.com','redux','redux.com','renren','renren.com','researchgate.net','reunion','reunion.com','reverbnation','reverbnation.com','rtl.de','ryze','ryze.com','salespider','salespider.com',
      'scoop.it','screenrant','screenrant.com','scribd','scribd.com','scvngr','scvngr.com','secondlife','secondlife.com','serverfault','serverfault.com','shareit','sharethis','sharethis.com','shvoong.com','sites.google.com','skype','skyrock','skyrock.com','slashdot.org',
      'slideshare.net','smartnews.com','snapchat','snapchat.com','sociallife.com.br','socialvibe','socialvibe.com','spaces.live.com','spoke','spoke.com','spruz','spruz.com','ssense.com','stackapps','stackapps.com','stackexchange','stackexchange.com','stackoverflow','stackoverflow.com',
      'stardoll.com','stickam','stickam.com','studivz.net','suomi24.fi','superuser','superuser.com','sweeva','sweeva.com','t.co','t.me','tagged','tagged.com','taggedmail','taggedmail.com','talkbiznow','talkbiznow.com','taringa.net','techmeme','techmeme.com','tencent','tencent.com','tiktok',
      'tiktok.com','tinyurl','tinyurl.com','toolbox','toolbox.com','touch.facebook.com','tr.pinterest.com','travellerspoint','travellerspoint.com','tripadvisor','tripadvisor.com','trombi','trombi.com','tudou','tudou.com','tuenti','tuenti.com','tumblr','tumblr.com','tweetdeck','tweetdeck.com',
      'twitter','twitter.com','twoo.com','typepad','typepad.com','unblog.fr','urbanspoon.com','ushareit.com','ushi.cn','vampirefreaks','vampirefreaks.com','vampirerave','vampirerave.com','vg.no','video.ibm.com','vk.com','vkontakte.ru','wakoopa','wakoopa.com','wattpad','wattpad.com','web.facebook.com',
      'web.skype.com','webshots','webshots.com','wechat','wechat.com','weebly','weebly.com','weibo','weibo.com','wer-weiss-was.de','weread','weread.com','whatsapp','whatsapp.com','wiki.answers.com','wikihow.com','wikitravel.org','woot.com','wordpress','wordpress.com','wordpress.org','xanga',
      'xanga.com','xing','xing.com','yahoo-mbga.jp','yammer','yammer.com','yelp','yelp.co.uk','yelp.com','youroom.in','za.pinterest.com','zalo','zoo.gr','zooppa','zooppa.com'
      )
      and REGEXP_CONTAINS(${traffic_source__medium}, r"^(.*cp.*|ppc|paid.*)$")
      then 'Paid Social'

      -- PAID VIDEO
      when ${traffic_source__source} IN (
      'blog.twitch.tv','crackle','crackle.com','curiositystream','curiositystream.com','d.tube','dailymotion',
      'dailymotion.com','dashboard.twitch.tv','disneyplus','disneyplus.com','fast.wistia.net','help.hulu.com',
      'help.netflix.com','hulu','hulu.com','id.twitch.tv','iq.com','iqiyi','iqiyi.com','jobs.netflix.com',
      'justin.tv','m.twitch.tv','m.youtube.com','music.youtube.com','netflix','netflix.com','player.twitch.tv',
      'player.vimeo.com','ted','ted.com','twitch','twitch.tv','utreon','utreon.com','veoh','veoh.com','viadeo.journaldunet.com',
      'vimeo','vimeo.com','wistia','wistia.com','youku','youku.com','youtube','youtube.com'
      )
      and REGEXP_CONTAINS(${traffic_source__medium}, r"^(.*cp.*|ppc|paid.*)$")
      then 'Paid Video'

      -- DISPLAY
      when REGEXP_CONTAINS(${traffic_source__medium}, r"^(display|cpm|banner|expandable|interstitial)$")
      then 'Display'

      -- ORGANIC SHOPPING
      when ${traffic_source__source} IN (
      'Google Shopping','IGShopping','aax-us-east.amazon-adsystem.com','aax.amazon-adsystem.com','alibaba',
      'alibaba.com','amazon','amazon.co.uk','amazon.com','apps.shopify.com','checkout.shopify.com','checkout.stripe.com',
      'cr.shopping.naver.com','cr2.shopping.naver.com','ebay','ebay.co.uk','ebay.com','ebay.com.au','ebay.de',
      'etsy','etsy.com','m.alibaba.com','m.shopping.naver.com','mercadolibre','mercadolibre.com','mercadolibre.com.ar',
      'mercadolibre.com.mx','message.alibaba.com','msearch.shopping.naver.com','nl.shopping.net','no.shopping.net','offer.alibaba.com',
      'one.walmart.com','order.shopping.yahoo.co.jp','partners.shopify.com','s3.amazonaws.com','se.shopping.net','shop.app','shopify',
      'shopify.com','shopping.naver.com','shopping.yahoo.co.jp','shopping.yahoo.com','shopzilla','shopzilla.com','simplycodes.com',
      'store.shopping.yahoo.co.jp','stripe','stripe.com','uk.shopping.net','walmart','walmart.com'
      )
      or REGEXP_CONTAINS(${campaign}, r"^(.*(([^a-df-z]|^)shop|shopping).*)$")
      then 'Organic Shopping'

      -- ORGANIC SOCIAL
      when ${traffic_source__source} IN (
      '43things','43things.com','51.com','5ch.net','Hatena','ImageShack','academia.edu','activerain','activerain.com','activeworlds','activeworlds.com','addthis','addthis.com','airg.ca','allnurses.com','allrecipes.com','alumniclass','alumniclass.com','ameba.jp',
      'ameblo.jp','americantowns','americantowns.com','amp.reddit.com','ancestry.com','anobii','anobii.com','answerbag','answerbag.com','answers.yahoo.com','aolanswers','aolanswers.com','apps.facebook.com','ar.pinterest.com','artstation.com','askubuntu',
      'askubuntu.com','asmallworld.com','athlinks','athlinks.com','away.vk.com','awe.sm','b.hatena.ne.jp','baby-gaga','baby-gaga.com','babyblog.ru','badoo','badoo.com','bebo','bebo.com','beforeitsnews','beforeitsnews.com','bharatstudent','bharatstudent.com',
      'biip.no','biswap.org','bit.ly','blackcareernetwork.com','blackplanet','blackplanet.com','blip.fm','blog.com','blog.feedspot.com','blog.goo.ne.jp','blog.naver.com','blog.yahoo.co.jp','blogg.no','bloggang.com','blogger','blogger.com','blogher','blogher.com',
      'bloglines','bloglines.com','blogs.com','blogsome','blogsome.com','blogspot','blogspot.com','blogster','blogster.com','blurtit','blurtit.com','bookmarks.yahoo.co.jp','bookmarks.yahoo.com','br.pinterest.com','brightkite','brightkite.com','brizzly','brizzly.com',
      'business.facebook.com','buzzfeed','buzzfeed.com','buzznet','buzznet.com','cafe.naver.com','cafemom','cafemom.com','camospace','camospace.com','canalblog.com','care.com','care2','care2.com','caringbridge.org','catster','catster.com','cbnt.io','cellufun',
      'cellufun.com','centerblog.net','chat.zalo.me','chegg.com','chicagonow','chicagonow.com','chiebukuro.yahoo.co.jp','classmates','classmates.com','classquest','classquest.com','co.pinterest.com','cocolog-nifty','cocolog-nifty.com','copainsdavant.linternaute.com',
      'couchsurfing.org','cozycot','cozycot.com','cross.tv','crunchyroll','crunchyroll.com','cyworld','cyworld.com','cz.pinterest.com','d.hatena.ne.jp','dailystrength.org','deluxe.com','deviantart','deviantart.com','dianping','dianping.com','digg','digg.com','diigo',
      'diigo.com','discover.hubpages.com','disqus','disqus.com','dogster','dogster.com','dol2day','dol2day.com','doostang','doostang.com','dopplr','dopplr.com','douban','douban.com','draft.blogger.com','draugiem.lv','drugs-forum','drugs-forum.com','dzone','dzone.com',
      'edublogs.org','elftown','elftown.com','epicurious.com','everforo.com','exblog.jp','extole','extole.com','facebook','facebook.com','faceparty','faceparty.com','fandom.com','fanpop','fanpop.com','fark','fark.com','fb','fb.me','fc2','fc2.com','feedspot','feministing',
      'feministing.com','filmaffinity','filmaffinity.com','flickr','flickr.com','flipboard','flipboard.com','folkdirect','folkdirect.com','foodservice','foodservice.com','forums.androidcentral.com','forums.crackberry.com','forums.imore.com','forums.nexopia.com',
      'forums.webosnation.com','forums.wpcentral.com','fotki','fotki.com','fotolog','fotolog.com','foursquare','foursquare.com','free.facebook.com','friendfeed','friendfeed.com','fruehstueckstreff.org','fubar','fubar.com','gaiaonline','gaiaonline.com',
      'gamerdna','gamerdna.com','gather.com','geni.com','getpocket.com','glassboard','glassboard.com','glassdoor','glassdoor.com','godtube','godtube.com','goldenline.pl','goldstar','goldstar.com','goo.gl','gooblog','goodreads','goodreads.com','google+',
      'googlegroups.com','googleplus','govloop','govloop.com','gowalla','gowalla.com','gree.jp','groups.google.com','gulli.com','gutefrage.net','habbo','habbo.com','hi5','hi5.com','hootsuite','hootsuite.com','houzz','houzz.com','hoverspot','hoverspot.com',
      'hr.com','hu.pinterest.com','hubculture','hubculture.com','hubpages.com','hyves.net','hyves.nl','ibibo','ibibo.com','id.pinterest.com','identi.ca','ig','imageshack.com','imageshack.us','imvu','imvu.com','in.pinterest.com','insanejournal','insanejournal.com','instagram',
      'instagram.com','instapaper','instapaper.com','internations.org','interpals.net','intherooms','intherooms.com','irc-galleria.net','is.gd','italki','italki.com','jammerdirect','jammerdirect.com','jappy.com','jappy.de','kaboodle.com','kakao','kakao.com','kakaocorp.com',
      'kaneva','kaneva.com','kin.naver.com','l.facebook.com','l.instagram.com','l.messenger.com','last.fm','librarything','librarything.com','lifestream.aol.com','line','line.me','linkedin','linkedin.com','listal','listal.com','listography','listography.com','livedoor.com',
      'livedoorblog','livejournal','livejournal.com','lm.facebook.com','lnkd.in','m.blog.naver.com','m.cafe.naver.com','m.facebook.com','m.kin.naver.com','m.vk.com','m.yelp.com','mbga.jp','medium.com','meetin.org','meetup','meetup.com','meinvz.net','meneame.net','menuism.com',
      'messages.google.com','messages.yahoo.co.jp','messenger','messenger.com','mix.com','mixi.jp','mobile.facebook.com','mocospace','mocospace.com','mouthshut','mouthshut.com','movabletype','movabletype.com','mubi','mubi.com','my.opera.com','myanimelist.net','myheritage','myheritage.com',
      'mylife','mylife.com','mymodernmet','mymodernmet.com','myspace','myspace.com','netvibes','netvibes.com','news.ycombinator.com','newsshowcase','nexopia','ngopost.org','niconico','nicovideo.jp','nightlifelink','nightlifelink.com','ning','ning.com','nl.pinterest.com','odnoklassniki.ru',
      'odnoklassniki.ua','okwave.jp','old.reddit.com','oneworldgroup.org','onstartups','onstartups.com','opendiary','opendiary.com','oshiete.goo.ne.jp','out.reddit.com','over-blog.com','overblog.com','paper.li','partyflock.nl','photobucket','photobucket.com','pinboard','pinboard.in','pingsta',
      'pingsta.com','pinterest','pinterest.at','pinterest.ca','pinterest.ch','pinterest.cl','pinterest.co.kr','pinterest.co.uk','pinterest.com','pinterest.com.au','pinterest.com.mx','pinterest.de','pinterest.es','pinterest.fr','pinterest.it','pinterest.jp','pinterest.nz','pinterest.ph',
      'pinterest.pt','pinterest.ru','pinterest.se','pixiv.net','pl.pinterest.com','playahead.se','plurk','plurk.com','plus.google.com','plus.url.google.com','pocket.co','posterous','posterous.com','pro.homeadvisor.com','pulse.yahoo.com','qapacity','qapacity.com','quechup',
      'quechup.com','quora','quora.com','qzone.qq.com','ravelry','ravelry.com','reddit','reddit.com','redux','redux.com','renren','renren.com','researchgate.net','reunion','reunion.com','reverbnation','reverbnation.com','rtl.de','ryze','ryze.com','salespider','salespider.com',
      'scoop.it','screenrant','screenrant.com','scribd','scribd.com','scvngr','scvngr.com','secondlife','secondlife.com','serverfault','serverfault.com','shareit','sharethis','sharethis.com','shvoong.com','sites.google.com','skype','skyrock','skyrock.com','slashdot.org',
      'slideshare.net','smartnews.com','snapchat','snapchat.com','sociallife.com.br','socialvibe','socialvibe.com','spaces.live.com','spoke','spoke.com','spruz','spruz.com','ssense.com','stackapps','stackapps.com','stackexchange','stackexchange.com','stackoverflow','stackoverflow.com',
      'stardoll.com','stickam','stickam.com','studivz.net','suomi24.fi','superuser','superuser.com','sweeva','sweeva.com','t.co','t.me','tagged','tagged.com','taggedmail','taggedmail.com','talkbiznow','talkbiznow.com','taringa.net','techmeme','techmeme.com','tencent','tencent.com','tiktok',
      'tiktok.com','tinyurl','tinyurl.com','toolbox','toolbox.com','touch.facebook.com','tr.pinterest.com','travellerspoint','travellerspoint.com','tripadvisor','tripadvisor.com','trombi','trombi.com','tudou','tudou.com','tuenti','tuenti.com','tumblr','tumblr.com','tweetdeck','tweetdeck.com',
      'twitter','twitter.com','twoo.com','typepad','typepad.com','unblog.fr','urbanspoon.com','ushareit.com','ushi.cn','vampirefreaks','vampirefreaks.com','vampirerave','vampirerave.com','vg.no','video.ibm.com','vk.com','vkontakte.ru','wakoopa','wakoopa.com','wattpad','wattpad.com','web.facebook.com',
      'web.skype.com','webshots','webshots.com','wechat','wechat.com','weebly','weebly.com','weibo','weibo.com','wer-weiss-was.de','weread','weread.com','whatsapp','whatsapp.com','wiki.answers.com','wikihow.com','wikitravel.org','woot.com','wordpress','wordpress.com','wordpress.org','xanga',
      'xanga.com','xing','xing.com','yahoo-mbga.jp','yammer','yammer.com','yelp','yelp.co.uk','yelp.com','youroom.in','za.pinterest.com','zalo','zoo.gr','zooppa','zooppa.com'
      )
      or REGEXP_CONTAINS(${traffic_source__medium}, r"(social|social-network|social-media|sm|social network|social media)")
      then 'Organic Social'

      -- ORGANIC VIDEO
      when ${traffic_source__source} IN (
      'blog.twitch.tv','crackle','crackle.com','curiositystream','curiositystream.com','d.tube','dailymotion',
      'dailymotion.com','dashboard.twitch.tv','disneyplus','disneyplus.com','fast.wistia.net','help.hulu.com',
      'help.netflix.com','hulu','hulu.com','id.twitch.tv','iq.com','iqiyi','iqiyi.com','jobs.netflix.com',
      'justin.tv','m.twitch.tv','m.youtube.com','music.youtube.com','netflix','netflix.com','player.twitch.tv',
      'player.vimeo.com','ted','ted.com','twitch','twitch.tv','utreon','utreon.com','veoh','veoh.com','viadeo.journaldunet.com',
      'vimeo','vimeo.com','wistia','wistia.com','youku','youku.com','youtube','youtube.com'
      )
      or REGEXP_CONTAINS(${traffic_source__medium}, r"^(.*video.*)$")
      then 'Organic Video'

      -- ORGANIC SEARCH
      when ${traffic_source__source} IN (
      '360.cn','alice','aol','ar.search.yahoo.com','ask','at.search.yahoo.com','au.search.yahoo.com','auone','avg',
      'babylon','baidu','biglobe','biglobe.co.jp','biglobe.ne.jp','bing','br.search.yahoo.com','ca.search.yahoo.com',
      'centrum.cz','ch.search.yahoo.com','cl.search.yahoo.com','cn.bing.com','cnn','co.search.yahoo.com','comcast',
      'conduit','cse.google.com','daum','daum.net','de.search.yahoo.com','dk.search.yahoo.com','dogpile','dogpile.com',
      'duckduckgo','ecosia.org','email.seznam.cz','eniro','es.search.yahoo.com','espanol.search.yahoo.com','exalead.com',
      'excite.com','fi.search.yahoo.com','firmy.cz','fr.search.yahoo.com','globo','go.mail.ru','google','google-play',
      'google.com','googlemybusiness','hk.search.yahoo.com','id.search.yahoo.com','in.search.yahoo.com','incredimail',
      'it.search.yahoo.com','kvasir','lite.qwant.com','lycos','m.baidu.com','m.naver.com','m.search.naver.com','m.sogou.com',
      'mail.google.com','mail.rambler.ru','mail.yandex.ru','malaysia.search.yahoo.com','msn','msn.com','mx.search.yahoo.com',
      'najdi','naver','naver.com','news.google.com','nl.search.yahoo.com','no.search.yahoo.com','ntp.msn.com','nz.search.yahoo.com',
      'onet','onet.pl','pe.search.yahoo.com','ph.search.yahoo.com','pl.search.yahoo.com','qwant','qwant.com','rakuten','rakuten.co.jp',
      'rambler','rambler.ru','se.search.yahoo.com','search-results','search.aol.co.uk','search.aol.com','search.google.com',
      'search.smt.docomo.ne.jp','search.ukr.net','secureurl.ukr.net','seznam','seznam.cz','sg.search.yahoo.com','so.com','sogou',
      'sogou.com','sp-web.search.auone.jp','startsiden','startsiden.no','suche.aol.de','terra','th.search.yahoo.com',
      'tr.search.yahoo.com','tut.by','tw.search.yahoo.com','uk.search.yahoo.com','ukr','us.search.yahoo.com','virgilio',
      'vn.search.yahoo.com','wap.sogou.com','webmaster.yandex.ru','websearch.rakuten.co.jp','yahoo','yahoo.co.jp','yahoo.com',
      'yandex','yandex.by','yandex.com','yandex.com.tr','yandex.fr','yandex.kz','yandex.ru','yandex.ua','yandex.uz','zen.yandex.ru'
      )
      or ${traffic_source__medium} = 'organic'
      then 'Organic Search'

      -- EMAIL
      when REGEXP_CONTAINS(${traffic_source__medium}, r"email|e-mail|e_mail|e mail")
      or REGEXP_CONTAINS(${traffic_source__source}, r"email|e-mail|e_mail|e mail")
      then 'Email'

      -- AFFILIATES
      when REGEXP_CONTAINS(${traffic_source__medium}, r"affiliate|affiliates")
      then 'Affiliates'

      -- REFERRAL
      when ${traffic_source__medium} = 'referral'
      then 'Referral'

      -- AUDIO
      when ${traffic_source__medium} = 'audio'
      then 'Audio'

      -- SMS
      when ${traffic_source__medium} = 'sms'
      then 'SMS'

      -- MOBILE PUSH NOTIFICATIONS
      when ${traffic_source__medium} like '%push'
      or REGEXP_CONTAINS(${traffic_source__medium}, r"^(mobile|notification)$")
      then 'Mobile Push Notifications'
      else '(Other)' end ;;
  }

  dimension: user_pseudo_id {
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
  }
  measure: count_of_events {
    type: count
  }
  measure: count_of_users {
    type: count_distinct
    sql: ${user_pseudo_id} ;;
  }
  measure: count_of_new_users {
    type: count_distinct
    sql: ${user_pseudo_id} ;;
    filters: [ga_session_number: "1"]
  }
  measure: count_of_sessions {
    type: count_distinct
    view_label: "Sessions"
    sql: ${unique_session_id} ;;
  }
  measure: first_event {
    hidden: yes
    type: date_time
    sql: MIN(${_event_raw}) ;;
  }
  measure: last_event {
    hidden: yes
    type: date_time
    sql: MAX(${_event_raw}) ;;
  }

  measure: landing_page {
    type: string
    hidden: yes
    sql: array_agg(case when ${page_views.page_view_rank_asc}=1 then ${page} end ignore nulls)[0] ;;
  }

    filter: current_date_range {
      type: date
      view_label: "_PoP"
      label: "1. Current Date Range"
      description: "Select the current date range you are interested in. Make sure any other filter on Event Date covers this period, or is removed."
      sql: ${period} IS NOT NULL ;;
      convert_tz: no
    }

    parameter: compare_to {
      view_label: "_PoP"
      description: "Select the templated previous period you would like to compare to. Must be used with Current Date Range filter"
      label: "2. Compare To:"
      type: unquoted
      allowed_value: {
        label: "Previous Period"
        value: "Period"
      }
      allowed_value: {
        label: "Previous Week"
        value: "Week"
      }
      allowed_value: {
        label: "Previous Month"
        value: "Month"
      }
      allowed_value: {
        label: "Previous Quarter"
        value: "Quarter"
      }
      allowed_value: {
        label: "Previous Year"
        value: "Year"
      }
      default_value: "Period"
      # view_label: "_PoP" view_label having been declared twice in the article
    }



## ------------------ HIDDEN HELPER DIMENSIONS  ------------------ ##

    dimension: days_in_period {
      # hidden:  yes
      view_label: "_PoP"
      description: "Gives the number of days in the current period date range"
      type: number
      sql: DATE_DIFF( DATE({% date_start current_date_range %}), DATE({% date_end current_date_range %}), DAY) ;;
    }

    dimension: period_2_start {
      # hidden:  yes
      view_label: "_PoP"
      description: "Calculates the start of the previous period"
      type: date
      sql:
        {% if compare_to._parameter_value == "Period" %}
        DATE_ADD(DATE({% date_start current_date_range %}), INTERVAL ${days_in_period} DAY)
        {% else %}
        DATE_SUB(DATE({% date_start current_date_range %}), INTERVAL 1 {% parameter compare_to %})
        {% endif %};;
      convert_tz: no
    }

    dimension: period_2_end {
      # hidden:  yes
      view_label: "_PoP"
      description: "Calculates the end of the previous period"
      type: date
      sql:
        {% if compare_to._parameter_value == "Period" %}
        DATE_SUB(DATE({% date_start current_date_range %}), INTERVAL 1 DAY)
        {% else %}
        DATE_SUB(DATE_SUB(DATE({% date_end current_date_range %}), INTERVAL 1 DAY), INTERVAL 1 {% parameter compare_to %})
        {% endif %};;
      convert_tz: no
    }

    dimension: day_in_period {
      hidden: yes
      description: "Gives the number of days since the start of each period. Use this to align the event dates onto the same axis, the axes will read 1,2,3, etc."
      type: number
      sql:
          {% if current_date_range._is_filtered %}
              CASE
              WHEN {% condition current_date_range %} ${_event_raw} {% endcondition %}
              THEN DATE_DIFF( DATE({% date_start current_date_range %}), ${event_date}, DAY) + 1
              WHEN ${event_date} between ${period_2_start} and ${period_2_end}
              THEN DATE_DIFF(${period_2_start}, ${event_date}, DAY) + 1
              END
          {% else %} NULL
          {% endif %}
          ;;
    }

    dimension: order_for_period {
      hidden: yes
      type: number
      sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${_event_raw} {% endcondition %}
            THEN 1
            WHEN ${event_date} between ${period_2_start} and ${period_2_end}
            THEN 2
            END
        {% else %}
            NULL
        {% endif %}
        ;;
    }

## ------------------ DIMENSIONS TO PLOT ------------------ ##

    dimension_group: date_in_period {
      description: "Use this as your grouping dimension when comparing periods. Aligns the previous periods onto the current period"
      label: "Current Period"
      type: time
      sql: DATE_SUB(DATE({% date_start current_date_range %}), INTERVAL (${day_in_period} - 1) DAY)  ;;
      view_label: "_PoP"
      timeframes: [
        date,
        hour_of_day,
        day_of_week,
        day_of_week_index,
        day_of_month,
        day_of_year,
        week_of_year,
        month,
        month_name,
        month_num,
        year]
      convert_tz: no
    }


    dimension: period {
      view_label: "_PoP"
      label: "Period"
      description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period' or 'Previous Period'"
      type: string
      order_by_field: order_for_period
      sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${_event_raw} {% endcondition %}
            THEN 'This {% parameter compare_to %}'
            WHEN ${event_date} between ${period_2_start} and ${period_2_end}
            THEN 'Last {% parameter compare_to %}'
            END
        {% else %}
            NULL
        {% endif %}
        ;;
    }


## ---------------------- TO CREATE FILTERED MEASURES ---------------------------- ##

    dimension: period_filtered_measures {
      hidden: yes
      description: "We just use this for the filtered measures"
      type: string
      sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${_event_raw} {% endcondition %} THEN 'this'
            WHEN ${event_date} between ${period_2_start} and ${period_2_end} THEN 'last'
          END
        {% else %} NULL {% endif %} ;;
    }

# Filtered measures

    measure: current_period_users {
      view_label: "_PoP"
      type: count_distinct
      sql: ${user_pseudo_id};;
      filters: [period_filtered_measures: "this"]
    }

    measure: previous_period_users {
      view_label: "_PoP"
      type: count_distinct
      sql: ${user_pseudo_id};;
      filters: [period_filtered_measures: "last"]
    }

    measure: sales_pop_change {
      view_label: "_PoP"
      label: "Total Sales period-over-period % change"
      type: number
      sql: CASE WHEN ${current_period_users} = 0
            THEN NULL
            ELSE (1.0 * ${current_period_users} / NULLIF(${previous_period_users} ,0)) - 1 END ;;
      value_format_name: percent_2
    }


}
