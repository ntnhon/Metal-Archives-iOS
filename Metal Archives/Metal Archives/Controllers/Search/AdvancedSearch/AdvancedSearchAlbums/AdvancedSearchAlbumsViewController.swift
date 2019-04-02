//
//  AdvancedSearchAlbumsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class AdvancedSearchAlbumsViewController: BaseAdvancedSearchTableViewController {
    @IBOutlet private weak var bandNameTextField: BaseTextField!
    @IBOutlet private weak var exactMatchBandNameSwitch: UISwitch!
    @IBOutlet private weak var releaseTitleTextField: BaseTextField!
    @IBOutlet private weak var exactMatchReleaseTitleSwitch: UISwitch!
    @IBOutlet private weak var fromYearMonthTextField: BaseTextField!
    @IBOutlet private weak var toYearMonthTextField: BaseTextField!
    @IBOutlet private weak var countryListLabel: UILabel!
    @IBOutlet private weak var cityStateProvinceTextField: BaseTextField!
    @IBOutlet private weak var labelNameTextField: BaseTextField!
    @IBOutlet private weak var indieLabelSwitch: UISwitch!
    @IBOutlet private weak var catalogNumberTextField: BaseTextField!
    @IBOutlet private weak var identifierTextField: BaseTextField!
    @IBOutlet private weak var recordingInformationTextField: BaseTextField!
    @IBOutlet private weak var versionDescriptionTextField: BaseTextField!
    @IBOutlet private weak var additionalNotesTextField: BaseTextField!
    @IBOutlet private weak var genreTextField: BaseTextField!
    @IBOutlet private weak var releaseTypesListLabel: UILabel!
    @IBOutlet private weak var releaseFormatsListLabel: UILabel!
    
    
    //Year/ month
    private var fromYearMonthPickerView: UIPickerView!
    private var toYearMonthPickerView: UIPickerView!
    private var selectedFromYear: Int?
    private var selectedFromMonth: Month?
    private var selectedToYear: Int?
    private var selectedToMonth: Month?
    private var yearsList: [Int]!
    
    private var selectedCountries: [Country] = []
    private var selectedReleaseTypes: [ReleaseType] = []
    private var selectedReleaseFormats: [ReleaseFormat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Advanced Search Albums"
        self.initPickers()
        self.initYearsList()
        self.updateCountryListLabel()
    }
    
    private func updateCountryListLabel() {
        self.countryListLabel.text = self.generateSelectedCoutriesString()
    }
    
    private func updateReleaseTypeLabel() {
        self.releaseTypesListLabel.text = self.generateSelectedReleaseTypeString()
    }
    
    private func updateReleaseFormatLabel() {
        self.releaseFormatsListLabel.text = self.generateSelectedReleaseFormatString()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let advancedSearchCountryListViewController as AdvancedSearchCountryListViewController:
            advancedSearchCountryListViewController.selectedCountries = self.selectedCountries
            advancedSearchCountryListViewController.delegate = self
            
        case let advancedSearchReleaseTypeListViewController as AdvancedSearchReleaseTypeListViewController:
            advancedSearchReleaseTypeListViewController.selectedReleaseTypes = self.selectedReleaseTypes
            advancedSearchReleaseTypeListViewController.delegate = self
            
        case let advancedSearchReleaseFormatListViewController as AdvancedSearchReleaseFormatListViewController:
            advancedSearchReleaseFormatListViewController.selectedReleaseFormats = self.selectedReleaseFormats
            advancedSearchReleaseFormatListViewController.delegate = self
            
        case let advancedSearchAlbumsResultsViewController as AdvancedSearchAlbumsResultsViewController:
            if let optionsList = sender as? String {
                advancedSearchAlbumsResultsViewController.optionsList = optionsList
            }
            
        default:
            break
        }
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
        
        //Release title
        optionsList += "releaseTitle="
        if let releaseTitle = self.releaseTitleTextField.text {
            optionsList += releaseTitle
        }
        optionsList += "&"
        
        //Exact release match
        let exactReleaseMatch = self.exactMatchReleaseTitleSwitch.isOn ? 1 : 0
        optionsList += "exactReleaseMatch=\(exactReleaseMatch)&"
        
        //From year
        optionsList += "releaseYearFrom="
        if let fromYear = self.selectedFromYear {
            optionsList += "\(fromYear)"
        }
        optionsList += "&"
        
        //From month
        optionsList += "releaseMonthFrom="
        if let fromMonth = self.selectedFromMonth {
            optionsList += "\(fromMonth)"
        }
        optionsList += "&"
        
        //To year
        optionsList += "releaseYearTo="
        if let toYear = self.selectedToYear {
            optionsList += "\(toYear)"
        }
        optionsList += "&"
        
        //To month
        optionsList += "releaseMonthTo="
        if let toMonth = self.selectedToMonth {
            optionsList += "\(toMonth)"
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
        
        //City, state, province
        optionsList += "location="
        if let cityStateProvince = self.cityStateProvinceTextField.text {
            optionsList += cityStateProvince
        }
        optionsList += "&"
        
        //Label
        optionsList += "releaseLabelName="
        if let labelName = self.labelNameTextField.text {
            optionsList += labelName
        }
        optionsList += "&"
        
        //Indie label
        let indieLabel = self.indieLabelSwitch.isOn ? 1 : 0
        optionsList += "indieLabel=\(indieLabel)&"
        
        //Catalog number
        optionsList += "releaseCatalogNumber="
        if let catalogNumber = self.catalogNumberTextField.text {
            optionsList += catalogNumber
        }
        optionsList += "&"
        
        //Identifier
        optionsList += "releaseIdentifiers="
        if let identifier = self.identifierTextField.text {
            optionsList += identifier
        }
        optionsList += "&"
        
        //Recording information
        optionsList += "releaseRecordingInfo="
        if let recordingInformation = self.recordingInformationTextField.text {
            optionsList += recordingInformation
        }
        optionsList += "&"
        
        //Version description
        optionsList += "releaseDescription="
        if let versionDescription = self.versionDescriptionTextField.text {
            optionsList += versionDescription
        }
        optionsList += "&"
        
        //Additional notes
        optionsList += "releaseNotes="
        if let additionalNotes = self.additionalNotesTextField.text {
            optionsList += additionalNotes
        }
        optionsList += "&"
        
        //Genre
        optionsList += "genre="
        if let genre = self.genreTextField.text {
            optionsList += genre
        }
        optionsList += "&"
        
        //Release type
        self.selectedReleaseTypes.forEach({
            optionsList += "releaseType[]=\($0.rawValue)&"
        })
        
        //Release format
        self.selectedReleaseFormats.forEach({
            optionsList += "releaseFormat[]=\($0.parameter)&"
        })
        
        self.performSegue(withIdentifier: "ShowResult", sender: optionsList)
        
        Analytics.logEvent(AnalyticsEvent.PerformAdvancedSearch, parameters: [AnalyticsParameter.SearchType: "Advanced Search Albums"])
    }
}

//MARK: - UIPickerView as keyboard for year month picker
extension AdvancedSearchAlbumsViewController {
    private func initPickers() {
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
            let buttonChoose = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AdvancedSearchAlbumsViewController.tappedToolBarDoneButton))
            buttonChoose.tintColor = Settings.currentTheme.titleColor
            toolbar.items = [buttonSpace, buttonChoose]
            toolbar.isUserInteractionEnabled = true
            
            return toolbar
        }
        
        self.fromYearMonthPickerView = pickerView()
        self.toYearMonthPickerView = pickerView()
        
        self.fromYearMonthTextField.inputView = self.fromYearMonthPickerView
        self.fromYearMonthTextField.inputAccessoryView = toolbarWithDoneButton()
        self.fromYearMonthTextField.delegate = self
        
        self.toYearMonthTextField.inputView = self.toYearMonthPickerView
        self.toYearMonthTextField.inputAccessoryView = toolbarWithDoneButton()
        self.toYearMonthTextField.delegate = self
    }
    
    @objc private func tappedToolBarDoneButton() {
        self.view.endEditing(true)
    }
    
    private func initYearsList() {
        self.yearsList = []
        for i in 0...thisYear-minimumYearOfFormation {
            self.yearsList.append(thisYear - i)
        }
    }
    
    private func updateFromYearMonthTextFieldText() {
        //Year can not be nil
        if let selectedFromYear = self.selectedFromYear {
            if let selectedFromMonth = self.selectedFromMonth {
                self.fromYearMonthTextField.text = "\(selectedFromMonth.shortForm) \(selectedFromYear)"
            } else {
                self.fromYearMonthTextField.text = "\(selectedFromYear)"
            }
        } else {
            self.fromYearMonthTextField.text = nil
        }
    }
    
    private func updateToYearMonthTextFieldText() {
        if let selectedToYear = self.selectedToYear {
            if let selectedToMonth = self.selectedToMonth {
                self.toYearMonthTextField.text = "\(selectedToMonth.shortForm) \(selectedToYear)"
            } else {
                self.toYearMonthTextField.text = "\(selectedToYear)"
            }
        } else {
            self.toYearMonthTextField.text = nil
        }
    }
}

//MARK: - UITableViewDelegate
extension AdvancedSearchAlbumsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension AdvancedSearchAlbumsViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.fromYearMonthTextField:
            self.selectedFromYear = nil
            self.selectedFromMonth = nil
            
        case self.toYearMonthTextField:
            self.selectedToYear = nil
            self.selectedToMonth = nil
            
        default: break
        }
        
        return true
    }
}

//MARK: - UIPickerViewDelegate
extension AdvancedSearchAlbumsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.fromYearMonthPickerView:
            if component == 0 {
                self.selectedFromMonth = Month.allCases[row]
            } else {
                self.selectedFromYear = self.yearsList[row]
            }
            
            self.updateFromYearMonthTextFieldText()
            
        case self.toYearMonthPickerView:
            if component == 0 {
                self.selectedToMonth = Month.allCases[row]
            } else {
                self.selectedToYear = self.yearsList[row]
            }
            
            self.updateToYearMonthTextFieldText()
            
        default: return
        }
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Year/month"])
    }
}

//MARK: - UIPickerViewDataSource
extension AdvancedSearchAlbumsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return Month.allCases.count
        case 1: return self.yearsList.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            let month = Month.allCases[row]
            return month.longForm
        case 1:
            let year = self.yearsList[row]
            return "\(year)"
        default: return nil
        }
    }
}

//MARK: - AdvancedSearchCountryListViewControllerDelegate
extension AdvancedSearchAlbumsViewController: AdvancedSearchCountryListViewControllerDelegate {
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

//MARK: - AdvancedSearchReleaseTypeListViewControllerDelegate
extension AdvancedSearchAlbumsViewController: AdvancedSearchReleaseTypeListViewControllerDelegate {
    func didUpdateSelectedReleaseTypes(_ releaseTypes: [ReleaseType]) {
        self.selectedReleaseTypes = releaseTypes
        self.updateReleaseTypeLabel()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Release types"])
    }
    
    private func generateSelectedReleaseTypeString() -> String {
        if self.selectedReleaseTypes.count == 0 || self.selectedReleaseTypes.count == ReleaseType.allCases.count {
            return "Any"
        } else {
            var releasesName: String = ""
            for i in 0..<self.selectedReleaseTypes.count {
                let eachRelease = self.selectedReleaseTypes[i]
                if i == self.selectedReleaseTypes.count - 1 {
                    releasesName.append("\(eachRelease.description)")
                } else {
                    releasesName.append("\(eachRelease.description), ")
                }
            }
            
            return releasesName
        }
    }
}

//MARK: - AdvancedSearchReleaseFormatListViewControllerDelegate
extension AdvancedSearchAlbumsViewController: AdvancedSearchReleaseFormatListViewControllerDelegate {
    func didUpdateSelectedReleaseFormats(_ releaseFormats: [ReleaseFormat]) {
        self.selectedReleaseFormats = releaseFormats
        self.updateReleaseFormatLabel()
        self.tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Release formats"])
    }
    
    private func generateSelectedReleaseFormatString() -> String {
        if self.selectedReleaseFormats.count == 0 || self.selectedReleaseFormats.count == ReleaseFormat.allCases.count {
            return "Any"
        } else {
            var releasesFormat: String = ""
            for i in 0..<self.selectedReleaseFormats.count {
                let eachReleaseFormat = self.selectedReleaseFormats[i]
                if i == self.selectedReleaseFormats.count - 1 {
                    releasesFormat.append("\(eachReleaseFormat.description)")
                } else {
                    releasesFormat.append("\(eachReleaseFormat.description), ")
                }
            }
            
            return releasesFormat
        }
    }
}
