//
//  DigitalClockExampleView.swift
//  Example
//
//  Created by liugang zhang on 2026/1/31.
//

import SwiftUI
import AwesomeAnimation

/// Example view demonstrating Digital Clock animation
struct DigitalClockExampleView: View {
    @State private var fontSize: CGFloat = 60
    @State private var foregroundColor: Color = .primary
    @State private var showBackground: Bool = false
    @State private var backgroundColor: Color = .clear

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Preview Section
                GroupBox("Preview") {
                    previewContent
                }

                // Configuration Section
                GroupBox("Configuration") {
                    configurationContent
                }

                // Code Example Section
                GroupBox("Code Example") {
                    codeExampleContent
                }
            }
            .padding()
        }
    }

    // MARK: - Preview Content

    private var previewContent: some View {
        VStack(spacing: 20) {
            clockView
            sizeButtons
        }
    }

    private var clockView: some View {
        DigitalClockView()
            .foregroundColor(foregroundColor)
            .font(.system(size: fontSize, weight: .bold, design: .serif))
            .frame(height: fontSize * 1.3)
            .padding(showBackground ? 20 : 0)
            .background(showBackground ? backgroundColor : Color.clear)
            .cornerRadius(showBackground ? 12 : 0)
    }

    private var sizeButtons: some View {
        HStack(spacing: 20) {
            Button("Small") {
                fontSize = 40
            }
            .buttonStyle(.bordered)

            Button("Medium") {
                fontSize = 60
            }
            .buttonStyle(.bordered)

            Button("Large") {
                fontSize = 80
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Configuration Content

    private var configurationContent: some View {
        VStack(alignment: .leading, spacing: 15) {
            colorPicker
            backgroundToggle
            if showBackground {
                backgroundColorPicker
            }
        }
    }

    private var colorPicker: some View {
        HStack {
            Text("Color:")
            Spacer()
            ColorPicker("Foreground", selection: $foregroundColor)
                .labelsHidden()
        }
    }

    private var backgroundToggle: some View {
        HStack {
            Text("Show Background")
            Spacer()
            Toggle("", isOn: $showBackground)
        }
    }

    private var backgroundColorPicker: some View {
        HStack {
            Text("Background Color:")
            Spacer()
            ColorPicker("Background", selection: $backgroundColor)
                .labelsHidden()
        }
    }

    // MARK: - Code Example Content

    private var codeExampleContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Usage")
                .font(.headline)

            Text("""
            DigitalClockView()
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            """)
            .font(.system(.caption, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

#Preview {
    DigitalClockExampleView()
}
