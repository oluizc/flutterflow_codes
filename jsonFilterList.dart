/// Filters, searches and sorts a list of JSON objects.
///
/// Parameters:
///
/// completeList: List of objects to be processed (returns [] if null)
/// search: Search string in format "field,value" or global search (ignores if null)
/// filters: Complex filters in format "(field,operator,value)" with AND/OR support (ignores if null)
/// sorting: Sorting in format "field,direction" where direction is ASC or DESC (keeps original order if null)
///
/// Usage examples:
///
/// Search: "name,John" or "John" (global search)
/// Filters: "(age,>,18)" or "(status,==,active)AND(type,!=,admin)"
/// Sorting: "name,ASC" or "date,DESC"
List<dynamic> jsonFilterList(
  List<dynamic>? completeList,
  String? filters,
  String? search,
  String? sorting,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  // If the list is null, return empty array
  if (completeList == null) {
    return [];
  }

  // Copy of the list to work with
  List<dynamic> filteredList = List.from(completeList);

  // 1. Apply search (ilike) with support for "key,value" format
  if (search != null && search.isNotEmpty) {
    List<String> searchParts = search.split(',');

    if (searchParts.length >= 2) {
      // Format "key,value"
      String searchKey = searchParts[0];
      String searchValue = searchParts.sublist(1).join(',').toLowerCase();

      filteredList = filteredList.where((item) {
        // Get the value of the specified field
        dynamic itemValue = _getFieldValue(item, searchKey);

        // If the field exists, check if it contains the search
        if (itemValue != null) {
          return itemValue.toString().toLowerCase().contains(searchValue);
        }
        return false;
      }).toList();
    } else {
      // Original behavior: search in the entire object
      String searchLower = search.toLowerCase();
      filteredList = filteredList.where((item) {
        // Convert the item to string and check if it contains the search
        final String itemString = jsonEncode(item).toLowerCase();
        return itemString.contains(searchLower);
      }).toList();
    }
  }

  // 2. Apply complex filters with new format
  if (filters != null && filters.isNotEmpty) {
    // Separate groups by logical operators
    List<String> groups = [];
    List<String> logicalOperators = [];

    // Identify AND and OR operators
    String remainingFilter = filters;
    while (remainingFilter.isNotEmpty) {
      // Find the next closing parenthesis
      int closingIndex = _findClosingParenthesis(remainingFilter);
      if (closingIndex == -1) break;

      // Extract the group
      String group = remainingFilter.substring(0, closingIndex + 1);
      groups.add(group);

      // Advance beyond the group
      remainingFilter = remainingFilter.substring(closingIndex + 1);

      // Check if there's a logical operator
      if (remainingFilter.startsWith("AND") || remainingFilter.startsWith("OR")) {
        logicalOperators.add(remainingFilter.startsWith("AND") ? "AND" : "OR");
        remainingFilter = remainingFilter.substring(3); // Skip "AND" or "OR"
      } else {
        // If there's no operator, we're done
        break;
      }
    }

    // If we identified at least one group
    if (groups.isNotEmpty) {
      // Apply the first group
      List<dynamic> filterResult =
          _applySimpleFilter(filteredList, groups[0]);

      // Apply subsequent groups with logical operators
      for (int i = 0; i < logicalOperators.length; i++) {
        List<dynamic> groupResult =
            _applySimpleFilter(filteredList, groups[i + 1]);

        if (logicalOperators[i] == "AND") {
          // Intersection - keep only items in both sets (using ID for comparison)
          filterResult = filterResult.where((item1) {
            return groupResult.any((item2) => _areSameItem(item1, item2));
          }).toList();
        } else if (logicalOperators[i] == "OR") {
          // Union - add items that are not in the result
          for (var item in groupResult) {
            if (!filterResult
                .any((existing) => _areSameItem(item, existing))) {
              filterResult.add(item);
            }
          }
        }
      }

      filteredList = filterResult;
    }
  }

  // 3. Apply sorting
  if (sorting != null && sorting.isNotEmpty) {
    final parts = sorting.split(',');
    if (parts.length == 2) {
      final field = parts[0];
      final direction = parts[1].toUpperCase();

      filteredList.sort((a, b) {
        dynamic valueA = _getFieldValue(a, field);
        dynamic valueB = _getFieldValue(b, field);

        // Sorting with type handling
        return _compareValues(valueA, valueB, direction);
      });
    }
  }

  return filteredList;
}

/// Compares two values for sorting
int _compareValues(dynamic valueA, dynamic valueB, String direction) {
  // Null handling
  if (valueA == null && valueB == null) return 0;
  if (valueA == null) return direction == 'ASC' ? -1 : 1;
  if (valueB == null) return direction == 'ASC' ? 1 : -1;

  // Compare strings
  if (valueA is String && valueB is String) {
    // Try to convert to numbers
    num? numA = num.tryParse(valueA);
    num? numB = num.tryParse(valueB);

    if (numA != null && numB != null) {
      return direction == 'ASC' ? numA.compareTo(numB) : numB.compareTo(numA);
    }

    // Try to convert to dates
    DateTime? dateA = _parseBrazilianDate(valueA);
    DateTime? dateB = _parseBrazilianDate(valueB);

    if (dateA != null && dateB != null) {
      return direction == 'ASC' ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    }

    // String comparison
    final comparison = valueA.compareTo(valueB);
    return direction == 'ASC' ? comparison : -comparison;
  }

  // Compare numbers
  if (valueA is num && valueB is num) {
    return direction == 'ASC'
        ? valueA.compareTo(valueB)
        : valueB.compareTo(valueA);
  }

  // Compare booleans
  if (valueA is bool && valueB is bool) {
    final comparison = valueA == valueB ? 0 : (valueA ? 1 : -1);
    return direction == 'ASC' ? comparison : -comparison;
  }

  // Fallback to string comparison
  return direction == 'ASC'
      ? valueA.toString().compareTo(valueB.toString())
      : valueB.toString().compareTo(valueA.toString());
}

/// Finds the index of the corresponding closing parenthesis
int _findClosingParenthesis(String text) {
  if (!text.startsWith("(")) return -1;

  int level = 0;
  for (int i = 0; i < text.length; i++) {
    if (text[i] == '(') level++;
    if (text[i] == ')') level--;

    if (level == 0) return i; // Found the corresponding closing
  }

  return -1; // No corresponding closing found
}

/// Applies a simple filter to a list
List<dynamic> _applySimpleFilter(List<dynamic> list, String filter) {
  // Remove outer parentheses
  String cleanFilter = filter;
  if (cleanFilter.startsWith('(') && cleanFilter.endsWith(')')) {
    cleanFilter = cleanFilter.substring(1, cleanFilter.length - 1);
  }

  // Extract filter parts (field,operation,value)
  List<String> parts = cleanFilter.split(',');
  if (parts.length < 3) return list;

  String field = parts[0];
  String operation = parts[1];
  String value = parts.sublist(2).join(','); // Join the rest as value

  // Apply the filter
  return list
      .where((item) => _evaluateCondition(item, field, operation, value))
      .toList();
}

/// Evaluates a condition on an item
bool _evaluateCondition(
    dynamic item, String field, String operation, String comparisonValue) {
  dynamic itemValue = _getFieldValue(item, field);

  // Handle null value
  if (itemValue == null) {
    if (operation == '==' && comparisonValue.toLowerCase() == 'null')
      return true;
    if (operation == '!=' && comparisonValue.toLowerCase() != 'null')
      return true;
    return false;
  }

  // Specific handling for booleans
  if (field == 'selected' || itemValue is bool) {
    bool? boolValue;

    // Convert values to boolean
    if (itemValue is String) {
      boolValue = itemValue.toLowerCase() == 'true';
    } else if (itemValue is bool) {
      boolValue = itemValue;
    }

    bool comparisonBool = comparisonValue.toLowerCase() == 'true';

    if (operation == '==') return boolValue == comparisonBool;
    if (operation == '!=') return boolValue != comparisonBool;
  }

  // Date handling
  DateTime? valueDate = null;
  DateTime? comparisonDate = null;

  // Try to convert to dates
  if (itemValue is String) {
    valueDate = _parseBrazilianDate(itemValue);
  }

  comparisonDate = _parseBrazilianDate(comparisonValue);

  if (valueDate != null && comparisonDate != null) {
    switch (operation) {
      case '==':
        return valueDate.isAtSameMomentAs(comparisonDate);
      case '!=':
        return !valueDate.isAtSameMomentAs(comparisonDate);
      case '>':
        return valueDate.isAfter(comparisonDate);
      case '>=':
        return valueDate.isAfter(comparisonDate) ||
            valueDate.isAtSameMomentAs(comparisonDate);
      case '<':
        return valueDate.isBefore(comparisonDate);
      case '<=':
        return valueDate.isBefore(comparisonDate) ||
            valueDate.isAtSameMomentAs(comparisonDate);
    }
  }

  // Number handling
  num? numericValue;
  num? numericComparison;

  if (itemValue is String) {
    numericValue = num.tryParse(itemValue);
  } else if (itemValue is num) {
    numericValue = itemValue;
  }

  numericComparison = num.tryParse(comparisonValue);

  if (numericValue != null && numericComparison != null) {
    switch (operation) {
      case '==':
        return numericValue == numericComparison;
      case '!=':
        return numericValue != numericComparison;
      case '>':
        return numericValue > numericComparison;
      case '>=':
        return numericValue >= numericComparison;
      case '<':
        return numericValue < numericComparison;
      case '<=':
        return numericValue <= numericComparison;
    }
  }

  // String operations
  switch (operation) {
    case '==':
      return itemValue.toString() == comparisonValue;
    case '!=':
      return itemValue.toString() != comparisonValue;
    case 'contains':
    case 'ilike':
      return itemValue
          .toString()
          .toLowerCase()
          .contains(comparisonValue.toLowerCase());
    case 'startsWith':
      return itemValue
          .toString()
          .toLowerCase()
          .startsWith(comparisonValue.toLowerCase());
    case 'endsWith':
      return itemValue
          .toString()
          .toLowerCase()
          .endsWith(comparisonValue.toLowerCase());
    case 'in':
      List<String> values = comparisonValue.split('|');
      return values.contains(itemValue.toString());
    default:
      return false;
  }
}

/// Gets the value of a field, supporting access to nested properties with dot notation
dynamic _getFieldValue(dynamic item, String field) {
  if (item == null) return null;

  // For fields with dot notation (e.g., "address.city")
  List<String> parts = field.split('.');
  dynamic value = item;

  for (String part in parts) {
    if (value is Map) {
      value = value[part];
    } else {
      return null; // Invalid path
    }

    if (value == null) break;
  }

  return value;
}

/// Checks if two objects represent the same item (by ID or direct comparison)
bool _areSameItem(dynamic item1, dynamic item2) {
  if (item1 is Map && item2 is Map) {
    // Compare by ID if available
    if (item1.containsKey('id') && item2.containsKey('id')) {
      return item1['id'] == item2['id'];
    }
  }

  // Fallback comparison by JSON
  return jsonEncode(item1) == jsonEncode(item2);
}

/// Tries to convert a string to DateTime in Brazilian format (dd/MM/yyyy)
DateTime? _parseBrazilianDate(String value) {
  final RegExp dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
  if (dateRegex.hasMatch(value)) {
    List<String> parts = value.split('/');
    try {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
  return null;

  /// MODIFY CODE ONLY ABOVE THIS LINE
}
