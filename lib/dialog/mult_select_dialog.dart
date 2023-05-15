import 'package:flutter/material.dart';
import '../util/multi_select_actions.dart';
import '../util/multi_select_item.dart';
import '../util/multi_select_list_type.dart';

/// A dialog containing either a classic checkbox style list, or a chip style list.
class MultiSelectDialog<T> extends StatefulWidget with MultiSelectActions<T> {
  /// List of items to select from.
  final List<MultiSelectItem<T>> items;

  /// The list of selected values before interaction.
  final List<T> initialValue;

  /// The text at the top of the dialog.
  final Widget? title;

  /// Fires when the an item is selected / unselected.
  final void Function(List<T>)? onSelectionChanged;

  /// Fires when confirm is tapped.
  final void Function(List<T>)? onConfirm;

  /// Toggles search functionality. Default is false.
  final bool searchable;

  /// Text on the confirm button.
  final Text? confirmText;

  /// Text on the cancel button.
  final Text? cancelText;

  /// An enum that determines which type of list to render.
  final MultiSelectListType? listType;

  /// Sets the color of the checkbox or chip when it's selected.
  final Color? selectedColor;

  /// Sets a fixed height on the dialog.
  final double? height;

  /// Sets a fixed width on the dialog.
  final double? width;

  /// Set the placeholder text of the search field.
  final String? searchHint;

  /// A function that sets the color of selected items based on their value.
  /// It will either set the chip color, or the checkbox color depending on the list type.
  final Color? Function(T)? colorator;

  /// The background color of the dialog.
  final Color? backgroundColor;

  /// The color of the chip body or checkbox border while not selected.
  final Color? unselectedColor;

  /// Icon button that shows the search field.
  final Icon? searchIcon;

  /// Icon button that hides the search field
  final Icon? closeSearchIcon;

  /// Style the text on the chips or list tiles.
  final TextStyle? itemsTextStyle;

  /// Style the text on the selected chips or list tiles.
  final TextStyle? selectedItemsTextStyle;

  /// Style the search text.
  final TextStyle? searchTextStyle;

  /// Style the search hint.
  final TextStyle? searchHintStyle;

  /// Moves the selected items to the top of the list.
  final bool separateSelectedItems;

  /// Set the color of the check in the checkbox
  final Color? checkColor;

  final Color? itemBackground;

  MultiSelectDialog({
    required this.items,
    required this.initialValue,
    this.title,
    this.onSelectionChanged,
    this.onConfirm,
    this.listType,
    this.searchable = false,
    this.confirmText,
    this.cancelText,
    this.selectedColor,
    this.searchHint,
    this.height,
    this.width,
    this.colorator,
    this.backgroundColor,
    this.unselectedColor,
    this.searchIcon,
    this.closeSearchIcon,
    this.itemsTextStyle,
    this.searchHintStyle,
    this.searchTextStyle,
    this.selectedItemsTextStyle,
    this.separateSelectedItems = false,
    this.checkColor,
    this.itemBackground,
  });

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<T>(items);
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  List<T> _selectedValues = [];
  bool _showSearch = false;
  List<MultiSelectItem<T>> _items;

  _MultiSelectDialogState(this._items);

  @override
  void initState() {
    super.initState();
    _selectedValues.addAll(widget.initialValue);

    for (int i = 0; i < _items.length; i++) {
      _items[i].selected = false;
      if (_selectedValues.contains(_items[i].value)) {
        _items[i].selected = true;
      }
    }

    if (widget.separateSelectedItems) {
      _items = widget.separateSelected(_items);
    }
  }

  /// Returns a CheckboxListTile
  Widget _buildListItem(MultiSelectItem<T> item) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: widget.unselectedColor ?? Colors.black54,
      ),
      child: CheckboxListTile(
        checkColor: widget.checkColor,
        value: item.selected,
        activeColor:
            widget.colorator != null ? widget.colorator!(item.value) ?? widget.selectedColor : widget.selectedColor,
        title: Text(
          item.label,
          style: item.selected ? widget.selectedItemsTextStyle : widget.itemsTextStyle,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          setState(() {
            _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked!);

            if (checked) {
              item.selected = true;
            } else {
              item.selected = false;
            }
            if (widget.separateSelectedItems) {
              _items = widget.separateSelected(_items);
            }
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  Widget _buildGridItem(MultiSelectItem<T> item) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor: widget.unselectedColor ?? Colors.black54,
      ),
      child: Material(
        color: item.selected ? widget.selectedColor : widget.itemBackground,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            bool checked = !item.selected;

            setState(() {
              _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);

              if (checked) {
                item.selected = true;
              } else {
                item.selected = false;
              }
              if (widget.separateSelectedItems) {
                _items = widget.separateSelected(_items);
              }
            });
            if (widget.onSelectionChanged != null) {
              widget.onSelectionChanged!(_selectedValues);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: item.icon == null ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.icon != null) ...[
                      item.icon!,
                    ],
                    Checkbox(
                      value: item.selected,
                      checkColor: widget.checkColor,
                      activeColor: widget.selectedColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (bool? checked) {
                        if (checked == null) return;

                        setState(() {
                          _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);

                          if (checked) {
                            item.selected = true;
                          } else {
                            item.selected = false;
                          }
                          if (widget.separateSelectedItems) {
                            _items = widget.separateSelected(_items);
                          }
                        });
                        if (widget.onSelectionChanged != null) {
                          widget.onSelectionChanged!(_selectedValues);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Text(
                    item.label,
                    style: item.selected ? widget.selectedItemsTextStyle : widget.itemsTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns a ChoiceChip
  Widget _buildChipItem(MultiSelectItem<T> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        backgroundColor: widget.unselectedColor,
        selectedColor: widget.colorator?.call(item.value) ??
            widget.selectedColor ??
            Theme.of(context).primaryColor.withOpacity(0.35),
        label: Text(
          item.label,
          style: item.selected
              ? TextStyle(
                  color: widget.selectedItemsTextStyle?.color ??
                      widget.colorator?.call(item.value) ??
                      widget.selectedColor?.withOpacity(1) ??
                      Theme.of(context).primaryColor,
                  fontSize: widget.selectedItemsTextStyle?.fontSize,
                )
              : widget.itemsTextStyle,
        ),
        selected: item.selected,
        onSelected: (checked) {
          if (checked) {
            item.selected = true;
          } else {
            item.selected = false;
          }
          setState(() {
            _selectedValues = widget.onItemCheckedChange(_selectedValues, item.value, checked);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.only(left: 16, right: 16, top: 24),
      title: widget.searchable == false
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.title ?? const Text("Select"),
                Transform.scale(
                  scale: 0.8,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(widget.selectedColor),
                      padding: MaterialStatePropertyAll(EdgeInsets.zero),
                      // padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 2, horizontal: 4)),
                    ),
                    onPressed: () {
                      widget.onConfirmTap(context, _selectedValues, widget.onConfirm);
                    },
                    child: widget.confirmText ??
                        Text(
                          'Done',
                          style: TextStyle(
                            color: widget.checkColor,
                          ),
                        ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _showSearch
                    ? Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          child: TextField(
                            style: widget.searchTextStyle,
                            decoration: InputDecoration(
                              hintStyle: widget.searchHintStyle,
                              hintText: widget.searchHint ?? "Search",
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: widget.selectedColor ?? Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              List<MultiSelectItem<T>> filteredList = [];
                              filteredList = widget.updateSearchQuery(val, widget.items);
                              setState(() {
                                if (widget.separateSelectedItems) {
                                  _items = widget.separateSelected(filteredList);
                                } else {
                                  _items = filteredList;
                                }
                              });
                            },
                          ),
                        ),
                      )
                    : widget.title ?? Text("Select"),
                IconButton(
                  icon: _showSearch
                      ? widget.closeSearchIcon ?? Icon(Icons.close)
                      : widget.searchIcon ?? Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        if (widget.separateSelectedItems) {
                          _items = widget.separateSelected(widget.items);
                        } else {
                          _items = widget.items;
                        }
                      }
                    });
                  },
                ),
              ],
            ),
      contentPadding: widget.listType == null || widget.listType == MultiSelectListType.LIST
          ? EdgeInsets.only(top: 12.0)
          : EdgeInsets.all(16),
      content: Container(
        height: widget.height,
        width: widget.width ?? MediaQuery.of(context).size.width * 0.73,
        child: widget.listType == null || widget.listType == MultiSelectListType.LIST
            ? ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildListItem(_items[index]);
                },
              )
            : widget.listType == MultiSelectListType.GRID
                ? GridView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return _buildGridItem(_items[index]);
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.5 / 1,
                    ),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      children: _items.map(_buildChipItem).toList(),
                    ),
                  ),
      ),
      // actions: <Widget>[
      //   TextButton(
      //     child: widget.cancelText ??
      //         Text(
      //           "CANCEL",
      //           style: TextStyle(
      //             color: (widget.selectedColor != null && widget.selectedColor != Colors.transparent)
      //                 ? widget.selectedColor!.withOpacity(1)
      //                 : Theme.of(context).primaryColor,
      //           ),
      //         ),
      //     onPressed: () {
      //       widget.onCancelTap(context, widget.initialValue);
      //     },
      //   ),
      //   TextButton(
      //     child: widget.confirmText ??
      //         Text(
      //           'OK',
      //           style: TextStyle(
      //             color: (widget.selectedColor != null && widget.selectedColor != Colors.transparent)
      //                 ? widget.selectedColor!.withOpacity(1)
      //                 : Theme.of(context).primaryColor,
      //           ),
      //         ),
      //     onPressed: () {
      //       widget.onConfirmTap(context, _selectedValues, widget.onConfirm);
      //     },
      //   )
      // ],
    );
  }
}
