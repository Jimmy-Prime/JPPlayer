# JPPlayer
A music player tries to mimic Spotify iPad app

## Get Started
- A Spotify developer account, and create an app
- A Spotify token swap/refresh server
- Fill in four strings in constants.m, build project and all done

> A client ID at your app page
```objective-c
NSString *SpotifyClientId = @"Client ID";
```
> A Spotify login redirect URL, should match the URL scheme in xcode project. If you have any problem, follow the tutorial at [this page](https://developer.spotify.com/technologies/spotify-ios-sdk/tutorial/)
```objective-c
NSString *SpotifyRedirectURL = @"YOUR REDIRECT URL";
```
> In order to swap and refresh token, you have to provide a token server. If you have no idea how to do it, look at the [example project](https://github.com/spotify/ios-sdk/blob/master/Demo%20Projects/spotify_token_swap.rb) in Spotify SDK or [this repository](https://github.com/simontaen/SpotifyTokenSwap) to create it at [heroku](https://dashboard.heroku.com/)
```objective-c
NSString *SpotifySwapURL = @"YOUR TOKEN SWAP URL";
NSString *SpotifyRefreshURL = @"YOUR TOKEN REFRESH URL";
```

## License

JPPlayer is released under the GPL 3.0 license. See [LICENSE](http://www.gnu.org/licenses/) for details.

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
