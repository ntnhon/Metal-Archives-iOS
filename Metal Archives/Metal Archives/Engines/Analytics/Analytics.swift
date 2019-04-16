//
//  Analytics.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

struct AnalyticsEvent {
    //Settins
    static let NumberOfSessions = "num_of_sessions"
    static let UseThemeDefault = "use_theme_default"
    static let UseThemeLight = "use_theme_light"
    static let UseThemeVintage = "use_theme_vintage"
    static let UseThemeUnicorn = "use_theme_unicorn"
    static let EnabledThumbnail = "enabled_thumbnail"
    static let DisabledThumbnail = "disabled_thumbnail"
    static let UseFontSizeDefault = "use_font_size_default"
    static let UseFontSizeMedium = "use_font_size_medium"
    static let UseFontSizeLarge = "use_font_size_large"
    static let TodayWidget1Section = "today_widget_1_section"
    static let TodayWidget2Sections = "today_widget_2_sections"
    //Fetch more
    static let FetchMore = "fetch_more"
    //Push Notification
    static let AllowPushNotification = "allow_push_notification"
    static let NotAllowPushNotification = "dont_allow_push_notification"
    //Homepage
    static let RefreshHomepage = "refresh_homepage"
    static let SelectAnItemInHomepage = "select_an_item_in_homepage"
    static let OpenFromShortcut = "open_from_shortcut"
    static let OpenFromWidget = "open_from_widget"
    //Top 100 Bands
    static let ChangeSectionInTop100Bands = "change_section_in_top_bands"
    static let SelectAnItemInTop100Bands = "select_an_item_in_top_bands"
    //Top 100 Albums
    static let ChangeSectionInTop100Albums = "change_section_in_top_albums"
    static let SelectAnItemInTop100Albums = "select_an_item_in_top_albums"
    //News Archives
    static let SelectAnItemInNews = "select_an_item_in_news"
    //Open URL
    static let OpenURLInBrowser = "open_url_in_browser"
    static let ShareURL = "share_url"
    //Latest additions
    static let RefreshLatestAdditions = "refresh_latest_additions"
    static let ChangeSectionInLatestAdditions = "change_section_in_latest_additions"
    static let ChangeMonthInLatestAdditions = "change_month_in_latest_additions"
    static let SelectAnItemInLatestAdditions = "select_an_item_in_latest_additions"
    //Latest updates
    static let RefreshLatestUpdates = "refresh_latest_updates"
    static let ChangeSectionInLatestUpdates = "change_section_in_latest_updates"
    static let ChangeMonthInLatestUpdates = "change_month_in_latest_updates"
    static let SelectAnItemInLatestUpdates = "select_an_item_in_latest_updates"
    //Latest reviews
    static let RefreshLatestReviews = "refres_latest_reviews"
    static let ChangeMonthInLatestReviews = "change_month_in_latest_reviews"
    static let SelectAnItemInLatestReviews = "select_an_item_in_latest_reviews"
    //Upcoming albums
    static let RefreshUpcomingAlbums = "refresh_upcoming_albums"
    static let SelectAnItemInUpcomingAlbums = "select_an_item_in_upcoming_albums"
    //Simple Search
    static let ChangeSimpleSearchType = "change_simple_search_type"
    static let FeelingLucky = "feeling_lucky"
    static let PerformSimpleSearch = "perform_simple_search"
    static let SelectASimpleSearchResult = "select_a_simple_search_result"
    //Advanced Search
    static let PerformAdvancedSearch = "perform_advanced_search"
    static let ChangeAdvancedSearchOption = "change_advanced_search_option"
    static let SelectAnAdvancedSearchResult = "select_an_advanced_search_result"
    static let RefreshAdvancedSearchBandResults = "refresh_advanced_search_band_results"
    static let RefreshAdvancedSearchSongResults = "refresh_advanced_search_song_results"
    static let RefreshAdvancedSearchAlbumResults = "refresh_advanced_search_album_results"
    //Browse Bands
    static let PerformBrowseBands = "perform_browse_bands"
    static let SelectABrowseBandsResult = "select_a_browse_bands_result"
    static let RefreshBrowseBandsResults = "refresh_browse_bands_results"
    //Browse Labels
    static let PerformBrowseLabels = "perform_browse_labels"
    static let SelectABrowseLabelsResult = "select_a_browse_labels_result"
    static let RefreshBrowseLabelsAlphabeticallyResults = "refresh_browse_labels_alphabetically_results"
    static let RefreshBrowseLabelsByCountryResults = "refresh_browse_labels_by_country_results"
    //Artist RIP
    static let RefreshArtistRIP = "refresh_artist_rip"
    static let SelectAnArtistRIP = "select_an_artist_rip"
    static let ChangeArtistRIPYear = "change_artist_rip_year"
    //Random Band
    static let RandomBand = "random_band"
    //Settings
    static let ChangeTheme = "change_theme"
    static let ChangeFontSize = "font_size"
    static let ChangeThumbnailEnabled = "change_thumbnail_enabled"
    static let ChangeWidgetSections = "change_widget_sections"
    static let ViewSettingsExplication = "view_settings_explication"
    static let ChangeDefaultDiscographyType = "change_default_discography_type"
    //About
    static let SelectAnAboutOption = "select_an_about_option"
    //Review
    static let MadeAReview = "made_a_review"
    static let ReviewLatter = "review_latter"
    //Band detail
    static let RefreshBand = "refresh_band"
    static let ViewBand = "view_band"
    static let ViewBandPhoto = "view_band_photo"
    static let ViewBandLogo = "view_band_logo"
    static let ViewBandAbout = "view_band_about"
    static let ViewBandLastModifiedDate = "view_band_last_modified_date"
    static let ViewBandOldNames = "view_band_old_names"
    static let ViewBandLastLabel = "view_band_last_label"
    static let ViewBandRelease = "view_band_release"
    static let ViewBandArtist = "view_band_artist"
    static let ViewBandReview = "view_band_review"
    static let ViewBandAllReviews = "view_band_all_reviews"
    static let ViewBandSimilarArtist = "view_band_similar_artist"
    static let ViewBandAllSimilarArtists = "view_band_all_similar_artists"
    static let ViewBandLink = "view_band_link"
    static let ViewBandAllLinks = "view_band_all_links"
    static let ChangeDiscographyType = "change_discography_type"
    static let ChangeMemberType = "change_member_type"
    static let ShareBand = "share_band"
    //Photo viewer
    static let MakeFunnyEyes = "make_funny_eyes"
    static let SaveFunnyEyesPhoto = "save_funny_eyes_photo"
    static let SavePhoto = "save_photo"
    static let ShareFunnyEyesPhoto = "share_funny_eyes_photo"
    static let SharePhoto = "share_photo"
    //Release detail
    static let RefreshRelease = "refresh_release"
    static let ViewRelease = "view_release"
    static let ViewReleaseCover = "view_release_cover"
    static let ViewReleaseLastModifiedDate = "view_release_last_modified_date"
    static let ViewLyric = "view_lyric"
    static let ViewReleaseArtist = "view_release_artist"
    static let ViewReleaseReview = "view_release_review"
    static let ViewReleaseOtherVersion = "view_release_other_version"
    static let ChangeLineUpType = "change_lineup_type"
    static let ShareRelease = "share_release"
    //Artist
    static let RefreshArtist = "refresh_artist"
    static let ViewArtist = "view_artist"
    static let ViewArtistPhoto = "view_artist_photo"
    static let ViewArtistBio = "view_artist_bio"
    static let ViewArtistRoleInBand = "view_artist_role_in_band"
    static let ViewArtistRoleInRelease = "view_artist_role_in_release"
    static let ViewArtistLink = "view_artist_link"
    static let ShareArtist = "share_artist"
    //Review detail
    static let RefreshReview = "refresh_review"
    static let ViewReview = "view_review"
    static let ViewReviewReleaseCover = "view_review_release_cover"
    static let ShareReview = "share_review"
    //Label
    static let ViewLabel = "view_label"
    static let ViewLabelLogo = "view_label_logo"
    static let ViewLabelWebsite = "view_label_website"
    static let ViewLabelParentLabel = "view_label_parent_label"
    static let ViewLabelLastModifiedDate = "view_label_last_modified_date"
    static let ViewLabelSubLabel = "view_label_sub_label"
    static let ViewLabelAllSubLabels = "view_label_all_sub_labels"
    static let ViewLabelCurrentRoster = "view_label_current_roster"
    static let ViewLabelAllCurrentRosters = "view_label_all_current_rosters"
    static let ViewLabelPastRoster = "view_label_past_roster"
    static let ViewLabelAllPastRosters = "view_label_all_past_rosters"
    static let ViewLabelRelease = "view_label_release"
    static let ViewLabelAllReleases = "view_label_all_releases"
    static let ViewLabelLink = "view_label_link"
    static let ViewLabelAllLinks = "view_label_all_links"
    static let ShareLabel = "share_label"
    static let RefreshLabel = "refresh_label"
    static let RefreshPastRoster = "refresh_past_roster"
    static let RefreshCurrentRoster = "refresh_current_roster"
    static let RefreshReleasesInLabelList = "refresh_releases_in_label_list"
    //Version History
    static let ViewVersionHistory = "view_version_history"
    //Check new version
    static let OpenAppStoreToUpdate = "open_app_store_to_update"
    static let UpdateNextTime = "update_next_time"
    static let SkipUpdate = "skip_update"
    static let ErrorCheckingUpdate = "error_checking_update"
    //Search tips
    static let ViewSearchTips = "view_search_tips"
}

struct AnalyticsParameter {
    static let Option = "option"
    static let SectionName = "section_name"
    static let Month = "month"
    static let Year = "year"
    static let Letter = "letter"
    static let Country = "country"
    static let Genre = "genre"
    static let Shortcut = "shortcut"
    static let WidgetItem = "widget_item"
    static let ItemType = "item_type"
    static let BandName = "band_name"
    static let BandCountry = "band_country"
    static let BandID = "band_id"
    static let ReleaseTitle = "release_title"
    static let ReleaseID = "release_id"
    static let ReleaseURL = "release_url"
    static let ArtistName = "artist_name"
    static let ArtistID = "artist_id"
    static let LabelName = "label_name"
    static let LabelID = "label_id"
    static let SearchType = "search_type"
    static let SearchTerm = "search_term"
    static let AdvancedSearchOption = "advanced_search_option"
    static let DiscographyType = "discography_type"
    static let MemberType = "member_type"
    static let LinkTitle = "link_title"
    static let SimilarBandName = "similar_band_name"
    static let SimilarBandID = "similar_band_id"
    static let SongTitle = "song_title"
    static let LineUpType = "lineup_type"
    static let ReviewTitle = "review_title"
}
