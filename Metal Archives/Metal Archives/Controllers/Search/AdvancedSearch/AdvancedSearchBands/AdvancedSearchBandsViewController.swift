//
//  AdvancedSearchBandsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class AdvancedSearchBandsViewController: BaseAdvancedSearchTableViewController {
    @IBOutlet private weak var bandNameTextField: BaseTextField!
    @IBOutlet private weak var exactMatchBandNameSwitch: UISwitch!
    @IBOutlet private weak var genreTextField: BaseTextField!
    @IBOutlet private weak var countryListLabel: UILabel!
    @IBOutlet private weak var fromYearTextField: BaseTextField!
    @IBOutlet private weak var toYearTextField: BaseTextField!
    @IBOutlet private weak var additionalNotesTextField: BaseTextField!
    @IBOutlet private weak var statusListLabel: UILabel!
    @IBOutlet private weak var lyricalThemesTextField: BaseTextField!
    @IBOutlet private weak var cityStateProvinceTextField: BaseTextField!
    @IBOutlet private weak var labelNameTextField: BaseTextField!
    @IBOutlet private weak var indieLabelSwitch: UISwitch!
    
    private var selectedCountries: [Country] = []
    private var selectedBandStatus: [BandStatus] = []
    
    //Year of formation
    private var fromYearPickerView: UIPickerView!
    private var toYearPickerView: UIPickerView!
    private var selectedFromYear: Int?
    private var selectedToYear: Int?
    private var yearsList: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Advanced Search Bands"
        self.updateCountryListLabel()
        self.updateStatusListLabel()
        self.initYearOfFormationPickers()
        self.initYearsList()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let advancedSearchCountryListViewController as AdvancedSearchCountryListViewController:
            advancedSearchCountryListViewController.selectedCountries = self.selectedCountries
            advancedSearchCountryListViewController.delegate = self
        
        case let advancedSearchBandStatusListViewController as AdvancedSearchBandStatusListViewController:
            advancedSearchBandStatusListViewController.selectedStatus = self.selectedBandStatus
            advancedSearchBandStatusListViewController.delegate = self
        case let advancedSearchBandsResultsViewController as AdvancedSearchBandsResultsViewController:
            if let optionsList = sender as? String {
                advancedSearchBandsResultsViewController.optionsList = optionsList
            }
        default:
            break
        }
    }
    
    private func updateCountryListLabel() {
        self.countryListLabel.text = self.generateSelectedCoutriesString()
    }
    
    private func updateStatusListLabel() {
        self.statusListLabel.text = self.generateSelectedBandStatusString()
    }
    
    override func performSearch() {
        var optionsList = ""
        
        //Band name
        optionsList += "bandName="
        if let bandName = self.bandNameTextField.text {
            optionsList += bandName
        }
        optionsList += "&"
        
        //Exact band match
        let exactBandMatch = self.exactMatchBandNameSwitch.isOn ? 1 : 0
        optionsList += "exactBandMatch=\(exactBandMatch)&"
        
        //Genre
        optionsList += "genre="
        if let genre = self.genreTextField.text {
            optionsList += genre
        }
        optionsList += "&"
        
        //Country
        if self.selectedCountries.count == 0 {
            optionsList += "country=&"
        } else if self.selectedCountries.count == 1 {
            optionsList += "country=\(self.selectedCountries[0].iso)&"
        } else {
            self.selectedCountries.forEach({
                optionsList += "country[]=\($0.iso)&"
            })
        }
        
        //From year
        optionsList += "yearCreationFrom="
        if let fromYear = self.fromYearTextField.text {
            optionsList += fromYear
        }
        optionsList += "&"
        
        //To Year
        optionsList += "yearCreationTo="
        if let toYear = self.toYearTextField.text {
            optionsList += toYear
        }
        optionsList += "&"
        
        //Additional notes
        optionsList += "bandNotes="
        if let additionalNotes = self.additionalNotesTextField.text {
            optionsList += additionalNotes
        }
        optionsList += "&"
        
        //Status
        if self.selectedBandStatus.count == 0 {
            optionsList += "status=&"
        } else if self.selectedBandStatus.count == 1 {
            optionsList += "status=\(self.selectedBandStatus[0].rawValue)&"
        } else {
            self.selectedBandStatus.forEach({
                optionsList += "status[]=\($0.rawValue)&"
            })
        }
        
        //Lyrical themes
        optionsList += "themes="
        if let themes = self.lyricalThemesTextField.text {
            optionsList += themes
        }
        optionsList += "&"
        
        //City, state, province
        optionsList += "location="
        if let cityStateProvince = self.cityStateProvinceTextField.text {
            optionsList += cityStateProvince
        }
        optionsList += "&"
        
        //Label
        optionsList += "bandLabelName="
        if let labelName = self.labelNameTextField.text {
            optionsList += labelName
        }
        optionsList += "&"
        
        //Indie label
        let indieLabel = self.indieLabelSwitch.isOn ? 1 : 0
        optionsList += "indieLabel=\(indieLabel)&"
        
        self.performSegue(withIdentifier: "ShowResult", sender: optionsList)
        
        Analytics.logEvent(AnalyticsEvent.PerformAdvancedSearch, parameters: [AnalyticsParameter.SearchType: "Advanced Search Bands"])
    }
    
}

//MARK: - UIPickerView as keyboard for yearOfFormationTextField
extension AdvancedSearchBandsViewController {
    private func initYearOfFormationPickers() {
        let pickerView: () -> UIPickerView = {
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            
            return pickerView
        }
        
        let toolbarWithDoneButton: () -> UIToolbar = {
            let toolbar = UIToolbar()
            toolbar.barStyle = .default
            toolbar.isTranslucent = true
            toolbar.sizeToFit()
            
            let buttonSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let buttonChoose = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AdvancedSearchBandsViewController.tappedToolBarDoneButton))
            buttonChoose.tintColor = Settings.currentTheme.titleColor
            toolbar.items = [buttonSpace, buttonChoose]
            toolbar.isUserInteractionEnabled = true
            
            return toolbar
        }
        
        self.fromYearPickerView = pickerView()
        self.toYearPickerView = pickerView()
        
        self.fromYearTextField.inputView = self.fromYearPickerView
        self.fromYearTextField.inputAccessoryView = toolbarWithDoneButton()
        self.fromYearTextField.delegate = self
        
        self.toYearTextField.inputView = self.toYearPickerView
        self.toYearTextField.inputAccessoryView = toolbarWithDoneButton()
        self.toYearTextField.delegate = self
    }
    
    @objc private func tappedToolBarDoneButton() {
        self.view.endEditing(true)
    }
    
    private func initYearsList() {
        let minimumYearOfFormation = 1960
        let thisYear = Calendar.current.component(.year, from: Date())
        
        self.yearsList = []
        for i in 0...thisYear-minimumYearOfFormation {
            self.yearsList.append(thisYear - i)
        }
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchBandsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - AdvancedSearchCountryListViewControllerDelegate
extension AdvancedSearchBandsViewController: AdvancedSearchCountryListViewControllerDelegate {
    func didUpdateSelectedCountries(_ selectedCountries: [Country]) {
        self.selectedCountries = selectedCountries
        self.updateCountryListLabel()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Countries list"])
    }
    
    private func generateSelectedCoutriesString() -> String {
        if self.selectedCountries.count == 0 {
            return "Any country"
        } else {
            var countriesName: String = ""
            for i in 0..<self.selectedCountries.count {
                let eachCountry = self.selectedCountries[i]
                if i == self.selectedCountries.count - 1 {
                    countriesName.append("\(eachCountry.name)")
                } else {
                    countriesName.append("\(eachCountry.name), ")
                }
            }
            
            return countriesName
        }
    }
}

//MARK: - UIPickerViewDelegate
extension AdvancedSearchBandsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedYear = self.yearsList[row]
        switch pickerView {
        case self.fromYearPickerView:
            self.fromYearTextField.text = "\(selectedYear)"
            self.selectedFromYear = selectedYear
        case self.toYearPickerView:
            self.toYearTextField.text = "\(selectedYear)"
            self.selectedToYear = selectedYear
        default: break
        }
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Year"])
    }
}

//MARK: - UIPickerViewDataSource
extension AdvancedSearchBandsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.yearsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let year = self.yearsList[row]
        return "\(year)"
    }
}

//MARK: - UITextFieldDelegate
extension AdvancedSearchBandsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.fromYearTextField:
            if self.fromYearTextField.text == nil {
                self.selectedFromYear = nil
            }
            
        case self.toYearTextField:
            if self.toYearTextField.text == nil {
                self.selectedToYear = nil
            }
            
        default: break
        }
    }
}

//MARK: - AdvancedSearchBandStatusListViewControllerDelegate
extension AdvancedSearchBandsViewController: AdvancedSearchBandStatusListViewControllerDelegate {
    func didUpdateSelectedStatus(_ selectedStatus: [BandStatus]) {
        self.selectedBandStatus = selectedStatus
        self.updateStatusListLabel()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Band status"])
    }
    
    private func generateSelectedBandStatusString() -> String {
        if self.selectedBandStatus.count == 0 || self.selectedBandStatus.count == BandStatus.allCases.count {
            return "Any"
        } else {
            var bandStatus: String = ""
            for i in 0..<self.selectedBandStatus.count {
                let eachStatus = self.selectedBandStatus[i]
                if i == self.selectedBandStatus.count - 1 {
                    bandStatus.append("\(eachStatus.description)")
                } else {
                    bandStatus.append("\(eachStatus.description), ")
                }
            }
            
            return bandStatus
        }
    }
}
