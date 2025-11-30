import 'package:flutter/material.dart';

/// A widget that displays text with highlighted search matches.
///
/// This widget searches through a list of queries in order and highlights
/// all occurrences of the **first matching query** found in the text.
/// The search is case-insensitive.
///
/// ## Features:
/// - Supports multiple search queries (searches in order, stops at first match)
/// - Case-insensitive matching
/// - Highlights all occurrences of the matching query
/// - Customizable highlight color and style
/// - Supports maxLines and overflow properties
///
/// ## Example Usage:
/// ```dart
/// // Single query search
/// HighlightedText.single(
///   text: 'Apple iPhone Pro Max',
///   searchQuery: 'iPhone',
/// )
///
/// // Multiple queries (stops at first match)
/// HighlightedText(
///   text: 'Apple iPhone Pro Max',
///   searchQueries: ['Samsung', 'iPhone', 'Apple'],
///   // Will highlight 'iPhone' only (first found match)
/// )
/// ```
class HighlightedText extends StatelessWidget {
  // ==================== Constructors ====================

  /// Creates a HighlightedText widget with multiple search queries.
  ///
  /// The widget searches through [searchQueries] in order and highlights
  /// all occurrences of the first query that matches.
  const HighlightedText({
    super.key,
    required this.text,
    this.searchQueries = const [],
    this.style,
    this.highlightColor = Colors.yellow,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  /// Creates a HighlightedText widget with a single search query.
  ///
  /// This is a convenience factory for the common case of searching
  /// for a single term.
  factory HighlightedText.single({
    Key? key,
    required String text,
    required String searchQuery,
    TextStyle? style,
    Color highlightColor = Colors.yellow,
    TextStyle? highlightStyle,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return HighlightedText(
      key: key,
      text: text,
      searchQueries: searchQuery.isEmpty ? [] : [searchQuery],
      style: style,
      highlightColor: highlightColor,
      highlightStyle: highlightStyle,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // ==================== Properties ====================

  /// The text to display and search within.
  final String text;

  /// List of search queries to highlight.
  ///
  /// The widget searches through each query in order and stops at the
  /// first query that has a match in [text]. All occurrences of that
  /// matching query will be highlighted.
  ///
  /// Empty strings in the list are ignored.
  final List<String> searchQueries;

  /// The base text style applied to the entire text.
  ///
  /// If null, uses the default [TextStyle].
  final TextStyle? style;

  /// The background color for highlighted text.
  ///
  /// Defaults to [Colors.yellow]. This is ignored if [highlightStyle]
  /// is provided.
  final Color highlightColor;

  /// Custom style for highlighted text.
  ///
  /// If provided, this overrides [highlightColor]. Use this for more
  /// control over the highlight appearance (e.g., text color, font weight).
  final TextStyle? highlightStyle;

  /// Maximum number of lines to display.
  ///
  /// If null, text can span unlimited lines.
  final int? maxLines;

  /// How to handle text overflow.
  ///
  /// Defaults to [TextOverflow.clip] when using RichText.
  final TextOverflow? overflow;

  // ==================== Build Method ====================

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? const TextStyle();

    // Step 1: Filter out empty queries
    final validQueries = searchQueries.where((q) => q.isNotEmpty).toList();

    // If no valid queries, return plain text
    if (validQueries.isEmpty) {
      return _buildPlainText(defaultStyle);
    }

    // Step 2: Find the first query that has a match
    final matchingQuery = _findFirstMatchingQuery(validQueries);

    // If no query matches, return plain text
    if (matchingQuery == null) {
      return _buildPlainText(defaultStyle);
    }

    // Step 3: Find all occurrences of the matching query
    final matches = _findAllMatches(matchingQuery);

    // Step 4: Build highlighted text spans
    final spans = _buildTextSpans(matches);

    // Step 5: Return the RichText widget
    return RichText(
      text: TextSpan(style: defaultStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  // ==================== Private Helper Methods ====================

  /// Builds a plain Text widget without highlighting.
  Widget _buildPlainText(TextStyle defaultStyle) {
    return Text(
      text,
      style: defaultStyle,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Finds the first query from the list that exists in the text.
  ///
  /// Returns null if no query matches.
  String? _findFirstMatchingQuery(List<String> queries) {
    final lowerText = text.toLowerCase();

    for (final query in queries) {
      if (lowerText.contains(query.toLowerCase())) {
        return query;
      }
    }

    return null;
  }

  /// Finds all positions where the query appears in the text.
  ///
  /// Returns a list of [_MatchInfo] containing start and end positions.
  List<_MatchInfo> _findAllMatches(String query) {
    final matches = <_MatchInfo>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int currentIndex = 0;
    int matchIndex = lowerText.indexOf(lowerQuery, currentIndex);

    // Find all occurrences
    while (matchIndex != -1) {
      matches.add(
        _MatchInfo(start: matchIndex, end: matchIndex + query.length),
      );

      // Move past this match to find the next one
      currentIndex = matchIndex + query.length;
      matchIndex = lowerText.indexOf(lowerQuery, currentIndex);
    }

    return matches;
  }

  /// Builds a list of TextSpan widgets with highlighting applied.
  List<TextSpan> _buildTextSpans(List<_MatchInfo> matches) {
    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in matches) {
      // Add non-highlighted text before this match
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: highlightStyle ?? TextStyle(backgroundColor: highlightColor),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text after the last match
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }
}

// ==================== Helper Classes ====================

/// Stores the start and end positions of a match in the text.
class _MatchInfo {
  /// Creates a match info with the given positions.
  const _MatchInfo({required this.start, required this.end});

  /// The starting index of the match (inclusive).
  final int start;

  /// The ending index of the match (exclusive).
  final int end;
}
