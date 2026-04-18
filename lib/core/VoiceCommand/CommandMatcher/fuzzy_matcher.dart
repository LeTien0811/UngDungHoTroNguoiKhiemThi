class FuzzyMatcher {
  static int _levenshtein(String s, String t) {
    int m = s.length;
    int n = t.length;

    List<List<int>> dp =
    List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        int cost = s[i - 1] == t[j - 1] ? 0 : 1;

        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[m][n];
  }

  static double similarity(String s1, String s2) {
    int distance = _levenshtein(s1, s2);
    int maxLen = s1.length > s2.length ? s1.length : s2.length;

    if (maxLen == 0) return 1.0;

    return 1.0 - (distance / maxLen);
  }
}