package com.akhileshgulia.gta6companion

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class NewsNativeAdFactory(
    private val layoutInflater: LayoutInflater
) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {

        val adView = layoutInflater.inflate(
            R.layout.news_native_ad,
            null
        ) as NativeAdView

        // =========================================================
        // FIND VIEWS
        // =========================================================

        val headlineView =
            adView.findViewById<TextView>(R.id.ad_headline)

        val bodyView =
            adView.findViewById<TextView>(R.id.ad_body)

        val callToActionView =
            adView.findViewById<Button>(R.id.ad_call_to_action)

        val iconView =
            adView.findViewById<ImageView>(R.id.ad_app_icon)

        val mediaView =
            adView.findViewById<MediaView>(R.id.ad_media)


        // =========================================================
        // REGISTER ASSET VIEWS
        // =========================================================

        adView.headlineView = headlineView
        adView.bodyView = bodyView
        adView.callToActionView = callToActionView
        adView.iconView = iconView
        adView.mediaView = mediaView


        // =========================================================
        // HEADLINE
        // =========================================================

        headlineView.text = nativeAd.headline


        // =========================================================
        // BODY
        // =========================================================

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }


        // =========================================================
        // CALL TO ACTION
        // =========================================================

        if (nativeAd.callToAction != null) {
            callToActionView.text =
                nativeAd.callToAction

            callToActionView.visibility =
                View.VISIBLE
        } else {
            callToActionView.visibility =
                View.GONE
        }


        // =========================================================
        // APP ICON
        // =========================================================

        if (nativeAd.icon != null) {
            iconView.setImageDrawable(
                nativeAd.icon!!.drawable
            )

            iconView.visibility =
                View.VISIBLE
        } else {
            iconView.visibility =
                View.GONE
        }


        // =========================================================
        // MEDIA VIEW
        // =========================================================

        if (nativeAd.mediaContent != null) {
            mediaView.visibility =
                View.VISIBLE
        } else {
            mediaView.visibility =
                View.GONE
        }


        // =========================================================
        // ATTACH NATIVE AD
        // =========================================================

        adView.setNativeAd(nativeAd)

        return adView
    }
}