import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:avm_global_web/controllers/global_context_service/global_context_service.dart';
import 'package:avm_global_web/routes/app_route_constants.dart';
import 'package:avm_global_web/view/home_page/home_page.dart';
import 'package:avm_global_web/view/jobs/jobs_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class MyAppRouter {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    observers: [observer],
    routes: [
      GoRoute(
        name: MyAppRouteConstants.homeRouteName,
        path: '/',
        pageBuilder: (context, state) {
          return MaterialPage(
            name: MyAppRouteConstants.homeRouteName,
            key: state.pageKey,
            child: MyHomePage(
              title: 'AVM GLobal Consultants',
              dropdownItems: const ['Avm Global Consultants'],
            ),
          );
        },
      ),
      GoRoute(
        name: MyAppRouteConstants.jobsRouteName,
        path: '/jobs',
        pageBuilder: (context, state) {
          final jobId = state.uri.queryParameters['id'];
          final query = state.uri.queryParameters['query'];
          return MaterialPage(
            name: MyAppRouteConstants.jobsRouteName,
            key: state.pageKey,
            child: JobsPage(
              initialJobId: jobId,
              initialSearchQuery: query,
            ),
          );
        },
      ),
        // GoRoute(
        //   name: MyAppRouteConstants.aboutPageRouteName,
        //   path: '/about',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: AboutPageScreen());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.adminRouteName,
        //   path: '/admin',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: AdminPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.homeRouteName,
        //   path: '/home',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: Homepage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.homeWebRouteName,
        //   path: '/homeweb',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: HomepageWeb());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.profileRouteName,
        //   path: '/profile',
        //   builder: (context, state) => ProfilePage(),
        //   pageBuilder: (context, state) {
        //     return  MaterialPage(child: ProfilePage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.adsPostedByYouInitialRouteName,
        //   path: '/adspostedbyyouinitial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: AdsPostedByYouInitialPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.profileRentResidentialRouteName,
        //   path: '/profilerentresidential',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: AdsPostedByYouRentResidentialPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.profileRentCommercialRouteName,
        //   path: '/profilerentcommercial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: AdsPostedByYouRentCommercialPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.profileSellResidentialRouteName,
        //   path: '/profilesellresidential',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: AdsPostedByYouSellResidentialPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.profileSellCommercialRouteName,
        //   path: '/profilesellcommercial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: AdsPostedByYouSellCommercialPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchInitialRouteName,
        //   path: '/searchinitial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: SearchInitialPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchInitialWebRouteName,
        //   path: '/searchinitialweb',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: SearchInitialWebPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchRentResidentialRouteName,
        //   path: '/searchrentresidential',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: SearchPageResidential());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchWebRentResidentialRouteName,
        //   path: '/searchwebrentresidential',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: SearchPageWebRentResidential());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchWebRentCommercialRouteName,
        //   path: '/searchwebrentcommercial',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: SearchPageWebRentCommercial());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchWebBuyResidentialRouteName,
        //   path: '/searchwebbuyresidential',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: SearchPageWebBuyResidential());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchWebBuyCommercialRouteName,
        //   path: '/searchwebbuycommercial',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: SearchPageWebBuyCommercial());
        //   },
        // ),
        //         GoRoute(
        //   name: MyAppRouteConstants.searchPlotsPageRouteName,
        //   path: '/searchplotspage',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: SearchPlotsPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchRentCommercialProductDetailRouteName,
        //   path: '/searchrentcommercialadsproductdetail/:id',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(
        //         child: SearchPageCommercialProductDetail(
        //       xid: state.pathParameters['id'],
        //     ));
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchSellResidentialProductDetailRouteName,
        //   path: '/searchsellresidentialadsproductdetail/:id',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(
        //         child: SearchPageSellResidentialProductDetail(
        //       xid: state.pathParameters['id'],
        //     ));
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchSellCommercialProductDetailRouteName,
        //   path: '/searchsellcommercialadsproductdetail/:id',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(
        //         child: SearchPageSellCommercialProductDetail(
        //       xid: state.pathParameters['id'],
        //     ));
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchRentResidentialProductDetailRouteName,
        //   path: '/searchrentresidentialadsproductdetail/:id',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(
        //         child: SearchPageResidentialProductDetail(
        //       xid: state.pathParameters['id'],
        //     ));
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchRentCommercialRouteName,
        //   path: '/searchrentcommercial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: SearchPageCommercial());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchBuyResidentialRouteName,
        //   path: '/searchbuyresidential',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: SearchPageBuyResidential());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.searchBuyCommercialRouteName,
        //   path: '/searchbuycommercial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: SearchPageBuyCommercial());
        //   },
        // ),
        // // GoRoute(
        // //   name: MyAppRouteConstants.recommendedInitialRouteName,
        // //   path: '/recommendedinitial',
        // //   pageBuilder: (context, state) {
        // //     return const MaterialPage(child: RecommendedFirstPage());
        // //   },
        // // ),
        // // GoRoute(
        // //   name: MyAppRouteConstants.recommendedRentResidentialRouteName,
        // //   path: '/recommendedrentresidential',
        // //   pageBuilder: (context, state) {
        // //     return const MaterialPage(child: RecommendedRentResidentialPage());
        // //   },
        // // ),
        // // GoRoute(
        // //   name: MyAppRouteConstants.recommendedRentCommercialRouteName,
        // //   path: '/recommendedrentcommercial',
        // //   pageBuilder: (context, state) {
        // //     return const MaterialPage(child: RecommendedRentCommercialPage());
        // //   },
        // // ),
        // // GoRoute(
        // //   name: MyAppRouteConstants.recommendedBuyResidentialRouteName,
        // //   path: '/recommendedbuyresidential',
        // //   pageBuilder: (context, state) {
        // //     return const MaterialPage(child: RecommendedSellResidentialPage());
        // //   },
        // // ),
        // // GoRoute(
        // //   name: MyAppRouteConstants.recommendedBuyCommercialRouteName,
        // //   path: '/recommendedbuycommercial',
        // //   pageBuilder: (context, state) {
        // //     return const MaterialPage(child: RecommendedSellCommercialPage());
        // //   },
        // // ),
        // GoRoute(
        //   name: MyAppRouteConstants.postRentAdRouteRouteName,
        //   path: '/postrentad',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: CreateRentAds());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.postSellAdRouteRouteName,
        //   path: '/postsellad',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: CreateSellAds());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.savedAdsInitialRouteName,
        //   path: '/savedadsinitial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: SavedAdsPages());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.likedRentResidentialRouteName,
        //   path: '/likedrentresidential',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: LikedRentResidentialAdsPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.likedRentCommercialRouteName,
        //   path: '/likedrentcommercial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: LikedRentCommercialAdsPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.likedBuyResidentialRouteName,
        //   path: '/likedbuyresidential',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: LikedBuyResidentialAdsPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.likedBuyCommercialRouteName,
        //   path: '/likedbuycommercial',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: LikedBuyCommercialAdsPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.imposterPageRouteName,
        //   path: '/imposterpage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: ImposterPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.eventPageRouteName,
        //   path: '/eventpage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: EventPage());
        //   },
        // ),
        // GoRoute(
        //   name:
        //       MyAppRouteConstants.recentRentResidentialPropertiesPageRouteName,
        //   path: '/recentrentresidentialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: RecentRentResidentialPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.recentRentCommercialPropertiesPageRouteName,
        //   path: '/recentrentcommercialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: RecentRentCommericalPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name:
        //       MyAppRouteConstants.recentSellResidentialPropertiesPageRouteName,
        //   path: '/recentsellresidentialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: RecentSellResidentialPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.recentSellCommercialPropertiesPageRouteName,
        //   path: '/recentsellcommercialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: RecentSellCommercialPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants
        //       .mostViewedRentResidentialPropertiesPageRouteName,
        //   path: '/mostviewedrentresidentialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: MostViewedRentResidentialPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants
        //       .mostViewedRentCommercialPropertiesPageRouteName,
        //   path: '/mostviewedrentcommercialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: MostViewedRentCommercialPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants
        //       .mostViewedSellResidentialPropertiesPageRouteName,
        //   path: '/mostviewedsellresidentialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: MostViewedSellResidentialPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants
        //       .mostViewedSellCommercialPropertiesPageRouteName,
        //   path: '/mostviewedsellcommercialpropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(
        //         child: MostViewedSellCommercialPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.oneBedroomPropertiesPageRouteName,
        //   path: '/onebedroompropertiespage',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: OneBedroomPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.twoBedroomPropertiesPageRouteName,
        //   path: '/twobedroompropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: TwoBedroomPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.threeBedroomPropertiesPageRouteName,
        //   path: '/threebedroompropertiespage',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: ThreeBedroomPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.fourBedroomPropertiesPageRouteName,
        //   path: '/fourbedroompropertiespage',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: FourBedroomPropertiesPage());
        //   },
        // ),
        //         GoRoute(
        //   name: MyAppRouteConstants.fiveBedroomPropertiesPageRouteName,
        //   path: '/fivebedroompropertiespage',
        //   pageBuilder: (context, state) {
        //     return MaterialPage(child: FiveBedroomPropertiesPage());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.topPropertiesRouteName,
        //   path: '/toppropertiespage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: TopPropertiesBlock());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.chatRouteName,
        //   path: '/chatpage',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: ChatsScreen());
        //   },
        // ),
        // GoRoute(
        //   name: MyAppRouteConstants.chatsAdminRouteName,
        //   path: '/chatsadminscreen',
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: ChatsAdminScreen());
        //   },
        // ),
    ]);
}
