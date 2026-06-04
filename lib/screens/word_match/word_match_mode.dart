enum WordMatchMode {
  wordMeaning,
  character,
  place;

  String get label {
    switch (this) {
      case WordMatchMode.wordMeaning:
        return 'Word Meaning';
      case WordMatchMode.character:
        return 'Bible Characters';
      case WordMatchMode.place:
        return 'Places & Events';
    }
  }
}
