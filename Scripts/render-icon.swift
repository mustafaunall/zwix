import AppKit

let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

let cornerRadius = size * 0.225
let rect = NSRect(x: 0, y: 0, width: size, height: size)
let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
path.addClip()

let gradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.29, green: 0.36, blue: 0.98, alpha: 1),
    NSColor(calibratedRed: 0.56, green: 0.32, blue: 0.94, alpha: 1)
])
gradient?.draw(in: rect, angle: -90)

let config = NSImage.SymbolConfiguration(pointSize: size * 0.5, weight: .semibold)
    .applying(.init(paletteColors: [.white]))
if let symbol = NSImage(systemSymbolName: "switch.2", accessibilityDescription: nil)?
    .withSymbolConfiguration(config) {
    let glyphSize = symbol.size
    let scale = (size * 0.52) / max(glyphSize.width, glyphSize.height)
    let drawSize = NSSize(width: glyphSize.width * scale, height: glyphSize.height * scale)
    let origin = NSPoint(x: (size - drawSize.width) / 2, y: (size - drawSize.height) / 2)
    symbol.draw(in: NSRect(origin: origin, size: drawSize), from: .zero, operation: .sourceOver, fraction: 1.0)
}

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:])
else {
    fatalError("failed to render icon")
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon-1024.png"
try png.write(to: URL(fileURLWithPath: outputPath))
print("wrote \(outputPath)")
