//
//  NFTView.swift
//  Moon Widget
//
//  Created by Ludovic ROULLIER on 14/01/2022.
//

import WidgetKit
import SwiftUI
import Intents

struct NFTEntry: TimelineEntry {
    let date: Date
    let nftImageURL: String
    let nftName: String
    let floorPrice: String
    let isEmpty: Bool
    let configuration: SelectNFTIntent
}

@main
struct NFTWidget: Widget {
    let kind: String = "NFT_Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectNFTIntent.self,
            provider: Provider()) { entry in
                NFTWidgetEntryView(entry: entry)
            }
            .supportedFamilies([.systemSmall, .systemLarge])
			.configurationDisplayName("Widgets.Display.Name".localized)
			.description("Widgets.Description".localized)
    }
}

struct NFTWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        
        if (!entry.isEmpty) {
            ZStack(alignment: .bottomLeading) {
                
                NetworkImage(url: URL(string: entry.nftImageURL))
                
                LinearGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0/255, green: 0/255, blue: 0/255, opacity: 0.35), .clear]), startPoint: .bottom, endPoint: .center)
                
                VStack(alignment: .leading) {
                    Text(entry.floorPrice)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .offset(y: 4)
                        .lineLimit(1)
                        .shadow(color: Color(.sRGB, red: 0/255, green: 0/255, blue: 0/255, opacity: 0.25), radius: 6, x: 0, y: 0)
                    
                    Text(entry.nftName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .padding(.bottom, 8.0)
                        .shadow(color: Color(.sRGB, red: 0/255, green: 0/255, blue: 0/255, opacity: 0.25), radius: 4, x: 0, y: 0)
                }
                .padding(.horizontal, 12.0)
            }
        } else {
            
            ZStack(alignment: .center) {
                
                Image("gradientBackground")
                    .centerCropped()
                    .brightness(-0.6)
                
                VStack(alignment: .center) {
					Text("Widgets.Empty".localized)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                        .frame(height: 10)
                    
					Text("Widgets.Empty.Add".localized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 12.0)
            }
        }
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }
}

struct NetworkImage: View {
    let url: URL?
    var body: some View {
        if let url = url, let imageData = try? Data(contentsOf: url), let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .centerCropped()
        }
    }
}

struct NFTWidgetPreviews: PreviewProvider {
    static var previews: some View {
        
        NFTWidgetEntryView(entry: NFTEntry(date: Date(), nftImageURL: "https://lh3.googleusercontent.com/8wZj0mVMGq2poWacZhflWaEXu1B3_czpBL6snzSlFL1l8XAnN0fyfULx6jRIu-Hz_4o2Ba2aYJQo3Gx0Yvz0bjuHvZIsf54Is-vZyg=w600", nftName: "Doggy #1344", floorPrice: "1.9", isEmpty: true, configuration: SelectNFTIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
