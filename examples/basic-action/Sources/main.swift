import Foundation
import Core

@main
struct BasicAction {
    static func main() async throws {
        // ====================================
        // 1. LEER INPUTS
        // ====================================

        Core.info(message: "Starting Basic Action...")

        let name = try Core.getInput(
            "name",
            options: InputOptions(required: true)
        )

        let greeting = try Core.getInput(
            "greeting",
            options: InputOptions(required: false)
        )

        let verbose = Core.getBooleanInput("verbose")

        // ====================================
        // 2. LOGGING
        // ====================================

        if verbose {
            Core.debug(message: "Verbose mode enabled")
            Core.debug(message: "Name: \(name)")
            Core.debug(message: "Greeting: \(greeting ?? "default")")
        }

        // ====================================
        // 3. PROCESAMIENTO
        // ====================================

        Core.startGroup(name: "Processing Input")

        let message: String
        if let customGreeting = greeting {
            message = "\(customGreeting), \(name)!"
        } else {
            message = "Hello, \(name)!"
        }

        Core.info(message: "Generated message: \(message)")

        Core.endGroup()

        // ====================================
        // 4. CREAR SUMMARY
        // ====================================

        let summary = Core.summary

        summary
            .addHeading("Basic Action Results", level: 1)
            .addRaw("Successfully processed input!", addEOL: true)
            .addSeparator()
            .addHeading("Details", level: 2)
            .addList([
                "Name: \(name)",
                "Greeting: \(greeting ?? "default")",
                "Message: \(message)"
            ])
            .addSeparator()
            .addCodeBlock("""
            // Example usage
            - uses: username/basic-action@v1
              with:
                name: '\(name)'
                greeting: '\(greeting ?? "Hello")'
            """, language: "yaml")

        try summary.write()

        // ====================================
        // 5. ESTABLECER OUTPUTS
        // ====================================

        Core.setOutput(name: "message", value: message)
        Core.setOutput(
            name: "timestamp",
            value: ISO8601DateFormatter().string(from: Date())
        )

        // ====================================
        // 6. FINALIZAR
        // ====================================

        Core.info(message: "Action completed successfully! ✅")
    }
}
