//
//  LineChartCell.swift
//  Eat Me
//
//  Created by Daniel Hilton on 15/10/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import UIKit
import Charts

class LineChartCell: UITableViewCell {

    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.highlightPerDragEnabled = false
        lineChart.highlightPerTapEnabled = false
        lineChart.legend.enabled = false
        lineChart.xAxis.spaceMin = 0.5
        lineChart.xAxis.spaceMax = 0.5
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
