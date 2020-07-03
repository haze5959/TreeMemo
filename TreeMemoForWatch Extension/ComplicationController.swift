//
//  ComplicationController.swift
//  TreeMemoForWatch Extension
//
//  Created by OGyu kwon on 2020/02/19.
//  Copyright © 2020 OGyu kwon. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
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
            default:
                handler(nil)
        }
    }
    
}
