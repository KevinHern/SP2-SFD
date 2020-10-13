class NavBar {
  int _pageIndex;
  int _navIndex;
  bool _onMainScreen;

  NavBar(int pageIndex, int navIndex){
    this._pageIndex = pageIndex;
    this._navIndex = navIndex;
    this._onMainScreen = true;
  }

  void setPageIndex(int pageIndex){ this._pageIndex = pageIndex; }
  void setNavIndex(int navIndex){ this._navIndex = navIndex; }
  void setOnMainScreen(bool isInMainScreen){ this._onMainScreen = isInMainScreen; }
  void setIndexes(int pageIndex, int navIndex){
    this._pageIndex = pageIndex;
    this._navIndex = navIndex;
  }
  void setBoth(int index){ this.setIndexes(index, index); }

  int getNavIndex(){ return this._navIndex; }
  int getPageIndex(){ return this._pageIndex; }
  bool isOnMainScreen(){ return this._onMainScreen; }
}