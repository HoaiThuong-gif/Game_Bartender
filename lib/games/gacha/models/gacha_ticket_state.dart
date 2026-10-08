enum GachaTicketState {
  idle,
  selecting,
  paperFocus,
  waitingForTear,
  tearing,
  numberReveal,
  prizeLookup,
  itemReveal,
  result;

  static const sealed = waitingForTear;
  static const revealed = numberReveal;
  static const highlighting = prizeLookup;
  static const disappearing = itemReveal;
  static const completed = result;
}
