export class RowStats {
  static compute(rows, matchedRows) {
    return { matched: matchedRows.length, total: rows.length }
  }

  static percentage(matched, total) {
    return total > 0 ? Math.round(matched / total * 100) : 0
  }
}
