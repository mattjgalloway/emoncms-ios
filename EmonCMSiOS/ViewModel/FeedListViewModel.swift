//
//  FeedListViewModel.swift
//  EmonCMSiOS
//
//  Created by Matt Galloway on 12/09/2016.
//  Copyright © 2016 Matt Galloway. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RxDataSources
import Realm
import RealmSwift
import RxRealm

class FeedListViewModel {

  struct FeedListItem {
    fileprivate let feed: Feed

    var name: String {
      return self.feed.name
    }

    var value: String {
      return self.feed.value.prettyFormat()
    }

    init(feed: Feed) {
      self.feed = feed
    }
  }

  struct Section: SectionModelType {
    private(set) var header: String
    private(set) var items: [FeedListItem]

    init(header: String, items: [FeedListItem]) {
      self.header = header
      self.items = items
    }

    typealias Item = FeedListItem
    init(original: Section, items: [FeedListItem]) {
      self = original
      self.items = items
    }
  }

  private let account: Account
  private let api: EmonCMSAPI
  private let realm: Realm

  private let disposeBag = DisposeBag()

  // Inputs
  let active = Variable<Bool>(false)
  let refresh = PublishSubject<()>()

  // Outputs
  private(set) var feeds: Driver<[Section]>
  private(set) var isRefreshing: Driver<Bool>

  init(account: Account, api: EmonCMSAPI) {
    self.account = account
    self.api = api
    self.realm = account.createRealm()

    self.feeds = Driver.never()
    self.isRefreshing = Driver.never()

    self.feeds = self.realm.objects(Feed.self)
      .asObservableArray()
      .map(self.feedsToSections)
      .asDriver(onErrorJustReturn: [])

    let isRefreshing = ActivityIndicator()
    self.isRefreshing = isRefreshing.asDriver()

    let becameActive = self.active.asObservable()
      .filter { $0 == true }
      .distinctUntilChanged()
      .becomeVoid()

    Observable.of(self.refresh, becameActive)
      .merge()
      .flatMapLatest { [weak self] () -> Observable<()> in
        guard let strongSelf = self else { return Observable.empty() }
        return strongSelf.api.feedList(account)
          .map(strongSelf.saveFeeds)
          .trackActivity(isRefreshing)
      }
      .subscribe()
      .addDisposableTo(self.disposeBag)
  }

  private func saveFeeds(_ feeds: [Feed]) throws {
    let realm = self.realm
    try realm.write {
      for feed in feeds {
        realm.add(feed, update: true)
      }
    }
  }

  private func feedsToSections(_ feeds: [Feed]) -> [Section] {
    var sectionBuilder: [String:[Feed]] = [:]
    for feed in feeds {
      let sectionFeeds: [Feed]
      if let existingFeeds = sectionBuilder[feed.tag] {
        sectionFeeds = existingFeeds
      } else {
        sectionFeeds = []
      }
      sectionBuilder[feed.tag] = sectionFeeds + [feed]
    }

    var sections: [Section] = []
    for section in sectionBuilder.keys.sorted(by: <) {
      let sortedSectionFeeds = sectionBuilder[section]!
        .sorted(by: { $0.name < $1.name })
        .map { feed in
          return FeedListItem(feed: feed)
        }
      sections.append(Section(header: section, items: sortedSectionFeeds))
    }

    return sections
  }

  func feedChartViewModel(forItem item: FeedListItem) -> FeedChartViewModel {
    return FeedChartViewModel(account: self.account, api: self.api, feed: item.feed)
  }

}
