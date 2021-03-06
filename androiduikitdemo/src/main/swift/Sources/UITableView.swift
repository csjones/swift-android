//
//  UITableView.swift
//  Android
//
//  Created by Marco Estrella on 7/23/18.
//

import Foundation
import Android
import java_swift

final public class UITableView: UIView {
    
    // MARK: - Properties
    
    /// The object that acts as the data source of the table view.
    public weak var dataSource: UITableViewDataSource? {
        didSet { loadAdapter() }
    }
    
    /// The object that acts as the delegate of the table view.
    public weak var delegate: UITableViewDelegate?
    
    public private(set) var style: UITableViewStyle = .plain
    
    /// The height of each row (that is, table cell) in the table view.
    public var rowHeight: CGFloat = UITableView.defaultRowHeight
    
    /// The estimated height of rows in the table view.
    public var estimatedRowHeight: CGFloat = 0.0
    
    /// The estimated height of section headers in the table view.
    public var estimatedSectionHeaderHeight: CGFloat = 0.0
    
    /// The estimated height of section footers in the table view.
    public var estimatedSectionFooterHeight: CGFloat = 0.0
    
    /// The style for table cells used as separators.
    public var separatorStyle: UITableViewCellSeparatorStyle = .singleLine
    
    /// The color of separator rows in the table view.
    //public var separatorColor: UIColor? = UITableView.defaultSeparatorColor
    
    /// Specifies the default inset of cell separators.
    //public var separatorInset: UIEdgeInsets = UITableView.defaultSeparatorInset
    
    /// The number of sections in the table view.
    public var numberOfSections: Int {
        
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    /// The table cells that are visible in the table view.
    ///
    /// The value of this property is an array containing `UITableViewCell` objects,
    /// each representing a visible cell in the table view.
    public var visibleCells: [UITableViewCell] {
        
        guard let cells = adapter?.visibleCells.values
            else { return [] }
        
        return Array(cells)
    }
    
    /// An array of index paths each identifying a visible row in the table view.
    public var indexPathsForVisibleRows: [IndexPath]? {
        
        guard let indexPaths = adapter?.visibleCells.keys
            else { return nil }
        
        return Array(indexPaths)
    }
    
    // MARK: - Private Properties
    
    internal static let defaultRowHeight: CGFloat = 44
    
    internal private(set) var registeredCells = [String: UITableViewCell.Type]()
    
    // can be reloaded
    fileprivate var adapter: UITableViewRecyclerViewAdapter?
    
    // only assigned once
    fileprivate var recyclerView: AndroidWidgetRecyclerView!
    
    // MARK: - Initialization
    
    /// Initializes and returns a table view object having the given frame and style.
    public required init(frame: CGRect, style: UITableViewStyle = .plain) {
        
        super.init(frame: frame)
        
        // UITableView properties
        self.style = style
        
        // setup Android view
        guard let context = AndroidContext(casting: UIScreen.main.activity)
            else { fatalError("Missing context") }
        
        recyclerView = AndroidWidgetRecyclerView(context: context)
        
        guard let recyclerView = recyclerView
            else { fatalError("Missing Android RecyclerView") }

        let frameDp = CGRect.applyDP(rect: frame)
        
        // set origin
        recyclerView.setX(x: Float(frameDp.minX))
        recyclerView.setY(y: Float(frameDp.minY))
        
        // set size
        recyclerView.layoutParams = Android.Widget.FrameLayout.FLayoutParams(width: Int(frameDp.width), height: Int(frameDp.height))
        
        recyclerView.layoutManager = AndroidWidgetRecyclerViewLinearLayoutManager(context: context)

        androidView.addView(recyclerView)
        
        let adapter = UITableViewRecyclerViewAdapter(tableView: self)
        
        self.adapter = adapter
        self.recyclerView?.adapter = adapter
    }
    
    // MARK: - Methods
    
    public func reloadData() {
        
        self.loadAdapter()
    }
    
    /// Registers a class for use in creating new table cells.
    public func register(_ cellClass: UITableViewCell.Type?,
                         forCellReuseIdentifier identifier: String) {
    
        assert(identifier.isEmpty == false, "Identifier must not be an empty string")
        
        registeredCells[identifier] = cellClass
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell {

        guard let adapter = self.adapter
            else { fatalError("No adapter configured") }
        
        // get cell from reusable cell pool
        guard let cell = adapter.reusableCells.values.first(where: { $0.reuseIdentifier == identifier })
            else { fatalError("No reusable cell for \(identifier)") }
        
        return cell
    }
    
    public func dequeueReusableCell(withIdentifier identifier: String,
                                    for indexPath: IndexPath) -> UITableViewCell {
        
        guard let adapter = self.adapter
            else { fatalError("No adapter configured") }
        
        // get cell from reusable cell pool
        guard let cell = adapter.reusableCells[indexPath]
            else { fatalError("No reusable cell for \(identifier)") }
        
        return cell
    }
    
    /// Returns the table cell at the specified index path.
    ///
    /// - Parameter indexPath: The index path locating the row in the table view.
    ///
    /// - Returns: An object representing a cell of the table,
    /// or `nil` if the cell is not visible or `indexPath` is out of range.
    public func cellForRow(at indexPath: IndexPath) -> UITableViewCell? {
        
        return adapter?.visibleCells[indexPath]
    }
    
    /// Returns an index path representing the row and section of a given table-view cell.
    ///
    /// - Returns: An index path representing the row and section of the cell, or nil if the index path is invalid.
    public func indexPath(for cell: UITableViewCell) -> IndexPath? {
        
        return adapter?.visibleCells.first(where: { $0.value === cell })?.key
    }
    
    // MARK: - Private Methods
    
    private func loadAdapter() {
        
        self.adapter?.notifyDataSetChanged()
    }
}

// MARK: - Supporting Types

public protocol UITableViewDataSource: class {
    
    func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
}

public extension UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
}

// MARK: - Android

internal class UITableViewRecyclerViewAdapter: AndroidWidgetRecyclerViewAdapter {
    
    internal private(set) weak var tableView: UITableView?
    
    /// Cells ready for reuse
    internal private(set) var reusableCells = [IndexPath: UITableViewCell]()
    
    /// All created cells
    internal private(set) var cells = Set<UITableViewCell>()
    
    internal private(set) var visibleCells = [IndexPath: UITableViewCell]()
    
    convenience init(tableView: UITableView) {
        self.init(javaObject: nil)
        bindNewJavaObject()
        
        self.tableView = tableView
    }
    
    required init(javaObject: jobject?) {
        super.init(javaObject: javaObject)
    }
    
    override func onCreateViewHolder(parent: Android.View.ViewGroup, viewType: Int?) -> AndroidWidgetRecyclerView.ViewHolder {
        
        guard let tableView = tableView else {
            fatalError("Missing TableView")
        }
        
        guard let (identifier, cellType) = tableView.registeredCells.first else {
            fatalError("No cells registered")
        }
        
        // create new cell
        let cell = cellType.init(reuseIdentifier: identifier)
        
        cell.androidView.setOnClickListener {
            
            guard let tableView = self.tableView
                else { assertionFailure("Missing table view"); return }
            
            guard let delegate = tableView.delegate
                else { assertionFailure("Missing delegate"); return }
            
            // FIXME: Convert position to indexPath, support multiple sections
            let indexPath = IndexPath(row: cell.viewHolder.adapterPosition, in: 0)
            
            delegate.tableView(tableView, didSelectRowAt: indexPath)
        }
        
        // hold strong reference to cell
        self.cells.insert(cell)
        
        // return Android view
        return cell.viewHolder
    }
    
    override func onBindViewHolder(holder: AndroidWidgetRecyclerView.ViewHolder, position: Int) {
        
        guard let viewHolder = holder as? UITableViewCellViewHolder
            else { fatalError("Invalid view holder \(holder)") }
        
        // configure cell
        guard let tableView = self.tableView
            else { assertionFailure("Missing table view"); return }
        
        guard let dataSource = tableView.dataSource
            else { assertionFailure("Missing data source"); return }
        
        guard let cell = viewHolder.cell
            else { assertionFailure("Missing cell"); return }
        
        // FIXME: Convert position to indexPath, support multiple sections
        let indexPath = IndexPath(row: position, in: 0)
        
        // add cell to reusable queue
        self.reusableCells[indexPath] = cell
        
        // data source should use `dequeueCell` to get an existing cell
        let returnedCell = dataSource.tableView(tableView, cellForRowAt: indexPath)
        
        // should not create new cells constantly
        assert(returnedCell === cell)
        
        // not reusable anymore
        self.reusableCells[indexPath] = nil
        
        // mark as visible
        self.visibleCells = self.visibleCells.filter({ $0.value !== cell })
        self.visibleCells[indexPath] = cell
    }
    
    override func getItemCount() -> Int {
        
        guard let tableView = tableView else {
            return 0
        }
        
        guard let dataSource = tableView.dataSource else {
            return 0
        }

        return dataSource.tableView(tableView, numberOfRowsInSection: dataSource.numberOfSections(in: tableView))
    }
}

internal struct UITableViewCellCache {
    
    let cell: UITableViewCell
    
    var indexPath: IndexPath?
    
    init(_ cell: UITableViewCell) {
        
        self.cell = cell
        self.indexPath = nil
    }
}

// MARK: - Supporting Types

/// The style of the table view.
public enum UITableViewStyle: Int {
    
    case plain
    case grouped
}

/// The position in the table view (top, middle, bottom) to which a given row is scrolled.
public enum UITableViewScrollPosition: Int {
    
    case none
    case top
    case middle
    case bottom
}

/// The type of animation when rows are inserted or deleted.
public enum UITableViewRowAnimation: Int {
    
    case fade
    case right
    case left
    case top
    case bottom
    case none
    case middle
    
    case automatic = 100
}

/// Requests icon to be shown in the section index of a table view.
///
/// If the data source includes this constant string in the array of strings it returns
/// in `sectionIndexTitles(for:)`, the section index displays a magnifying glass icon at
/// the corresponding index location. This location should generally be the first title in the index.
// http://stackoverflow.com/questions/235120/whats-the-uitableview-index-magnifying-glass-character
public let UITableViewIndexSearch: String = "{search}"

/// The default value for a given dimension.
///
/// Requests that UITableView use the default value for a given dimension.
public let UITableViewAutomaticDimension: CGFloat = -1.0

open class UITableViewRowAction {
    
}

public protocol UITableViewDelegate: class /* UIScrollViewDelegate */ {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
    //func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    
    //func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
}

public extension UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return tableView.rowHeight }
    
    //func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return tableView.sectionHeaderHeight }
    
    //func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return tableView.sectionFooterHeight }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return tableView.estimatedRowHeight }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { return tableView.estimatedSectionHeaderHeight }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat { return tableView.estimatedSectionFooterHeight }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?  { return nil }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool  { return true }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?  { return indexPath }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return .delete }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { return nil }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { return nil }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) { }
    
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        return proposedDestinationIndexPath
    }
}
