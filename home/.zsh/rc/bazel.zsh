alias br="b r"

b() {
  local cmd=$1
  shift

  case $cmd in
    b|build)
      bazel build "$@"
      ;;
    r|run)
      bazel run --ui_event_filters=-info,-stdout,-stderr --noshow_progress -- "$@"
      ;;
    t|test)
      if [[ "$@" == "" ]]; then
        bazel test --test_output=errors //...
      else
        bazel test --test_output=errors "$@"
      fi
      ;;
    *)
      bazel "$@"
      ;;
  esac
}
