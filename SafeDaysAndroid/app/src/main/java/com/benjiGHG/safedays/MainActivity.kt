package com.benjiGHG.safedays

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.card.MaterialCardView
import java.text.DateFormat
import java.util.Date
import java.util.concurrent.TimeUnit

class MainActivity : AppCompatActivity() {
    private val prefs by lazy { getSharedPreferences("safe_days", MODE_PRIVATE) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        bindCard(R.id.self_harm_card, "❤️", "Ohne Selbstverletzung", "Jeder sichere Tag zählt.", "self_harm_start")
        bindCard(R.id.alcohol_card, "💧", "Ohne Alkohol", "Dein alkoholfreier Streak.", "alcohol_start")
    }

    private fun bindCard(cardId: Int, icon: String, title: String, subtitle: String, prefKey: String) {
        val card = findViewById<MaterialCardView>(cardId)
        val iconView = card.findViewById<TextView>(R.id.icon)
        val titleView = card.findViewById<TextView>(R.id.title)
        val subtitleView = card.findViewById<TextView>(R.id.subtitle)
        val daysView = card.findViewById<TextView>(R.id.days)
        val labelView = card.findViewById<TextView>(R.id.days_label)
        val sinceView = card.findViewById<TextView>(R.id.since)
        val reset = card.findViewById<Button>(R.id.reset)

        iconView.text = icon
        titleView.text = title
        subtitleView.text = subtitle

        fun refresh() {
            var start = prefs.getLong(prefKey, 0L)
            if (start == 0L) {
                start = System.currentTimeMillis()
                prefs.edit().putLong(prefKey, start).apply()
            }
            val days = TimeUnit.MILLISECONDS.toDays(System.currentTimeMillis() - start).coerceAtLeast(0)
            daysView.text = days.toString()
            labelView.text = if (days == 1L) "Tag" else "Tage"
            sinceView.text = "📅 Seit ${DateFormat.getDateInstance(DateFormat.MEDIUM).format(Date(start))}"
        }

        reset.setOnClickListener {
            prefs.edit().putLong(prefKey, System.currentTimeMillis()).apply()
            refresh()
        }

        refresh()
    }
}
