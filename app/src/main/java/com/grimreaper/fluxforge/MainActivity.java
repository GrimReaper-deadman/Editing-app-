package com.grimreaper.fluxforge;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {
    private WebView w;
    public ValueCallback<Uri[]> u;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        w = new WebView(this);
        WebSettings s = w.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setAllowFileAccess(true);
        s.setAllowFileAccessFromFileURLs(true);
        s.setAllowUniversalAccessFromFileURLs(true);
        w.setWebViewClient(new WebViewClient());
        w.setWebChromeClient(new ChromeClient(this));
        w.loadUrl("file:///android_asset/index.html");
        setContentView(w);
    }

    @Override
    protected void onActivityResult(int r, int sc, Intent i) {
        if (r == 1 && u != null) {
            Uri[] res = (sc == RESULT_OK && i != null) ? new Uri[]{Uri.parse(i.getDataString())} : null;
            u.onReceiveValue(res);
            u = null;
        }
    }
}

class ChromeClient extends WebChromeClient {
    MainActivity a;
    ChromeClient(MainActivity a) { this.a = a; }
    @Override
    public boolean onShowFileChooser(WebView w, ValueCallback<Uri[]> f, FileChooserParams p) {
        if (a.u != null) a.u.onReceiveValue(null);
        a.u = f;
        a.startActivityForResult(p.createIntent(), 1);
        return true;
    }
}
