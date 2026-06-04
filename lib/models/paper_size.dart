enum PaperSize {
  mm80,
  mm105,
}

extension PaperSizeX on PaperSize {
  String get label {
    switch (this) {
      case PaperSize.mm80:
        return '80mm';
      case PaperSize.mm105:
        return '105mm';
    }
  }

  int get pixelWidth {
    switch (this) {
      case PaperSize.mm80:
        return 576;
      case PaperSize.mm105:
        return 832;
    }
  }
}
