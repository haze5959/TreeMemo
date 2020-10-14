//
//  ComplicationController.swift
//  TreeMmoForWatch Extension
//
//  Created by OGyu kwon on 2020/10/08.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

    @available(watchOSApplicationExtension 7.0, *)
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "treeMemo", supportedFamilies: CLKComplicationFamily.allCases)
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    @available(watchOSApplicationExtension 7.0, *)
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        switch complication.family {
        case .circularSmall:
            let image: UIImage = UIImage(named: "Complication/Circular")!
            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .utilitarianSmall:
            let image: UIImage = UIImage(named: "Complication/Utilitarian")!
            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .modularSmall:
            let image: UIImage = UIImage(named: "Complication/Modular")!
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .graphicCorner:
            let image: UIImage = UIImage(named: "Complication/Graphic Corner")!
            let template = CLKComplicationTemplateGraphicCornerTextImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            template.textProvider = CLKTextProvider(format: "Tree Memo")
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        default:
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler(nil)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .circularSmall:
            let image: UIImage = UIImage(named: "Complication/Circular")!
            let template = CLKComplicationTemplateCircularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            handler(template)
        case .utilitarianSmall:
            let image: UIImage = UIImage(named: "Complication/Utilitarian")!
            let template = CLKComplicationTemplateUtilitarianSmallSquare()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            handler(template)
        case .modularSmall:
            let image: UIImage = UIImage(named: "Complication/Modular")!
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: image)
            handler(template)
        case .graphicCorner:
            let image: UIImage = UIImage(named: "Complication/Graphic Corner")!
            let template = CLKComplicationTemplateGraphicCornerTextImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
            template.textProvider = CLKTextProvider(format: "Tree Memo")
            handler(template)
        default:
            handler(nil)
        }
    }
}
