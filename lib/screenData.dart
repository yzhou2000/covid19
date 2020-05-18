class ScreenData {
  final String _county;
  final String _state;
  final String _msa;
  final String _state_name;
  ScreenData(this._county, this._state, this._msa, this._state_name);

  String get county => _county;
  String get state => _state;
  String get msa => _msa;
  String get state_name => _state_name;
}
