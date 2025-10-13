function stats() {
  gawk '
    {
      total += $1;
      if (min == "" || $1 < min) min = $1;
      if (max == "" || $1 > max) max = $1;
      input[NR] = $1;
    }
    END {
      mean = total / NR;

      d = 0;
      for (i in input) {
        n = input[i];
        d += (n - mean) ** 2;
      }
      variance = d / NR;
      d /= NR - 1;
      stddev = sqrt(d);

      low_outliers = 0;
      high_outliers = 0;
      for (i in input) {
        n = input[i];
        if (n >= (mean + (2 * stddev))) high_outliers += 1;
        if (n <= (mean - (2 * stddev))) low_outliers += 1;
      }
      total_outliers = low_outliers + high_outliers;

      asort(input);
      if (NR % 2 == 0) {
        n1 = NR / 2;
        n2 = n1 + 1;
        median = (input[n1] + input[n2]) / 2;
      } else {
        n1 = (NR + 1) / 2;
        median = input[n1];
      }
      p50 = input[int(NR*0.50 - 0.5)]
      p90 = input[int(NR*0.90 - 0.5)]
      p99 = input[int(NR*0.99 - 0.5)]

      printf "min: %g\n", min;
      printf "max: %g\n", max;
      printf "range: %g\n", max - min;
      printf "mean: %g\n", mean;
      printf "median: %g\n", median;
      printf "variance: %g\n", variance;
      printf "stddev: %g\n", stddev;
      printf "outliers: %g", total_outliers;
      if (total_outliers > 0) {
        printf " (%d high, %d low)", high_outliers, low_outliers;
      }
      printf "\n";
      printf "p50: %g\n", p50;
      printf "p90: %g\n", p90;
      printf "p99: %g\n", p99;
    }
  '
}
