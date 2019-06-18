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
    
    deinit {
        print("AdvancedSearchBandsViewController is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCountryListLabel()
        updateStatusListLabel()
        initYearOfFormationPickers()
        initYearsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView?.setTitle("Advanced Search Bands")
        simpleNavigationBarView.setRightButtonIcon(#imageLiteral(resourceName: "search"))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.performSearch()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let advancedSearchCountryListViewController as AdvancedSearchCountryListViewController:
            advancedSearchCountryListViewController.selectedCountries = selectedCountries
            advancedSearchCountryListViewController.delegate = self
            advancedSearchCountryListViewController.simpleNavigationBarView = simpleNavigationBarView
        
        case let advancedSearchBandStatusListViewController as AdvancedSearchBandStatusListViewController:
            advancedSearchBandStatusListViewController.selectedStatus = selectedBandStatus
            advancedSearchBandStatusListViewController.delegate = self
            advancedSearchBandStatusListViewController.simpleNavigationBarView = simpleNavigationBarView
            
        case let advancedSearchBandsResultsViewController as AdvancedSearchBandsResultsViewController:
            if let optionsList = sender as? String {
                advancedSearchBandsResultsViewController.optionsList = optionsList
                advancedSearchBandsResultsViewController.simpleNavigationBarView = simpleNavigationBarView
            }
        default:
            break
        }
    }
    
    private func updateCountryListLabel() {
        countryListLabel.text = generateSelectedCoutriesString()
    }
    
    private func updateStatusListLabel() {
        statusListLabel.text = generateSelectedBandStatusString()
    }
    
    func performSearch() {
        var optionsList = ""
        
        //Band name
        optionsList += "bandName="
        if let bandName = bandNameTextField.text {
            optionsList += bandName
        }
        optionsList += "&"
        
        //Exact band match
        let exactBandMatch = exactMatchBandNameSwitch.isOn ? 1 : 0
        optionsList += "exactBandMatch=\(exactBandMatch)&"
        
        //Genre
        optionsList += "genre="
        if let genre = genreTextField.text {
            optionsList += genre
        }
        optionsList += "&"
        
        //Country
        if selectedCountries.count == 0 {
            optionsList += "country=&"
        } else if selectedCountries.count == 1 {
            optionsList += "country=\(selectedCountries[0].iso)&"
        } else {
            selectedCountries.forEach({
                optionsList += "country[]=\($0.iso)&"
            })
        }
        
        //From year
        optionsList += "yearCreationFrom="
        if let fromYear = fromYearTextField.text {
            optionsList += fromYear
        }
        optionsList += "&"
        
        //To Year
        optionsList += "yearCreationTo="
        if let toYear = toYearTextField.text {
            optionsList += toYear
        }
        optionsList += "&"
        
        //Additional notes
        optionsList += "bandNotes="
        if let additionalNotes = additionalNotesTextField.text {
            optionsList += additionalNotes
        }
        optionsList += "&"
        
        //Status
        if selectedBandStatus.count == 0 {
            optionsList += "status=&"
        } else if selectedBandStatus.count == 1 {
            optionsList += "status=\(selectedBandStatus[0].rawValue)&"
        } else {
            selectedBandStatus.forEach({
                optionsList += "status[]=\($0.rawValue)&"
            })
        }
        
        //Lyrical themes
        optionsList += "themes="
        if let themes = lyricalThemesTextField.text {
            optionsList += themes
        }
        optionsList += "&"
        
        //City, state, province
        optionsList += "location="
        if let cityStateProvince = cityStateProvinceTextField.text {
            optionsList += cityStateProvince
        }
        optionsList += "&"
        
        //Label
        optionsList += "bandLabelName="
        if let labelName = labelNameTextField.text {
            optionsList += labelName
        }
        optionsList += "&"
        
        //Indie label
        let indieLabel = indieLabelSwitch.isOn ? 1 : 0
        optionsList += "indieLabel=\(indieLabel)&"
        
        performSegue(withIdentifier: "ShowResult", sender: optionsList)
        
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
        
        fromYearPickerView = pickerView()
        toYearPickerView = pickerView()
        
        fromYearTextField.inputView = fromYearPickerView
        fromYearTextField.inputAccessoryView = toolbarWithDoneButton()
        fromYearTextField.delegate = self
        
        toYearTextField.inputView = toYearPickerView
        toYearTextField.inputAccessoryView = toolbarWithDoneButton()
        toYearTextField.delegate = self
    }
    
    @objc private func tappedToolBarDoneButton() {
        view.endEditing(true)
    }
    
    private func initYearsList() {
        let minimumYearOfFormation = 1960
        let thisYear = Calendar.current.component(.year, from: Date())
        
        yearsList = []
        for i in 0...thisYear-minimumYearOfFormation {
            yearsList.append(thisYear - i)
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
        updateCountryListLabel()
        tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Countries list"])
    }
    
    private func generateSelectedCoutriesString() -> String {
        if selectedCountries.count == 0 {
            return "Any country"
        } else {
            var countriesName: String = ""
            for i in 0..<selectedCountries.count {
                let eachCountry = selectedCountries[i]
                if i == selectedCountries.count - 1 {
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
        let selectedYear = yearsList[row]
        switch pickerView {
        case fromYearPickerView:
            fromYearTextField.text = "\(selectedYear)"
            selectedFromYear = selectedYear
        case toYearPickerView:
            toYearTextField.text = "\(selectedYear)"
            selectedToYear = selectedYear
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
        return yearsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let year = yearsList[row]
        return "\(year)"
    }
}

//MARK: - UITextFieldDelegate
extension AdvancedSearchBandsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case fromYearTextField:
            if fromYearTextField.text == nil {
                selectedFromYear = nil
            }
            
        case toYearTextField:
            if toYearTextField.text == nil {
                selectedToYear = nil
            }
            
        default: break
        }
    }
}

//MARK: - AdvancedSearchBandStatusListViewControllerDelegate
extension AdvancedSearchBandsViewController: AdvancedSearchBandStatusListViewControllerDelegate {
    func didUpdateSelectedStatus(_ selectedStatus: [BandStatus]) {
        selectedBandStatus = selectedStatus
        updateStatusListLabel()
        tableView.reloadData()
        
        Analytics.logEvent(AnalyticsEvent.ChangeAdvancedSearchOption, parameters: [AnalyticsParameter.AdvancedSearchOption: "Band status"])
    }
    
    private func generateSelectedBandStatusString() -> String {
        if selectedBandStatus.count == 0 || selectedBandStatus.count == BandStatus.allCases.count {
            return "Any"
        } else {
            var bandStatus: String = ""
            for i in 0..<selectedBandStatus.count {
                let eachStatus = selectedBandStatus[i]
                if i == selectedBandStatus.count - 1 {
                    bandStatus.append("\(eachStatus.description)")
                } else {
                    bandStatus.append("\(eachStatus.description), ")
                }
            }
            
            return bandStatus
        }
    }
}
