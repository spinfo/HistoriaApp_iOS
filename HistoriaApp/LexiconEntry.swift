//
//  LexiconEntry.swift
//  HistoriaApp
//
//  Created by David on 22.09.17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

import GRDB

class LexiconEntry : Record {

    // the backend's id for this lexicon entry
    var id: Int64 = 0

    // the lexicon article's title
    var title: String = ""

    // the html content of the lexicon page
    var content: String = ""

    // get the actual content that should be displayed for the page
    func getPresentationContent() -> String {
        let localContent = HtmlContentCompletion.setTitle(self.title, on: self.content)
        return HtmlContentCompletion.wrapInPage(localContent)
    }

    // MARK: Record interface

    /// The table name
    override public class var databaseTableName: String {
        return "lexiconentry"
    }

    /// Allow blank initialization
    public override init() {
        super.init()
    }

    /// Initialize from a database row
    public required init(row: Row) {
        id = row.value(named: "id")
        title = row.value(named: "title")
        content = row.value(named: "content")
        super.init(row: row)
    }

    /// The values persisted in the database
    override public func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["title"] = title
        container["content"] = content
    }

}
