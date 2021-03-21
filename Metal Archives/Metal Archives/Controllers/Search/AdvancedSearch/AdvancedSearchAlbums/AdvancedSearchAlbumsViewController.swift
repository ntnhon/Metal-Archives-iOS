//
//  AdvancedSearchAlbumsViewController.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import FirebaseAnalytics
import UIKit

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
        initPickers()
        initYearsList()
        updateCountryListLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        simpleNavigationBarView.setTitle("Advanced Search Albums")
        simpleNavigationBarView.setRightButtonIcon(UIImage(named: "search"))
        simpleNavigationBarView.didTapRightButton = { [unowned self] in
            self.performSearch()
        }
        simpleNavigationBarView.isHidden = false
    }

    private func updateCountryListLabel() { countryListLabel.text = generateSelectedCoutriesString() }

    private func updateReleaseTypeLabel() { releaseTypesListLabel.text = generateSelectedReleaseTypeString() }

    private func updateReleaseFormatLabel() {
        releaseFormatsListLabel.text = generateSelectedReleaseFormatString()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let advancedSearchCountryListViewController as AdvancedSearchCountryListViewController:
            advancedSearchCountryListViewController.selectedCountries = selectedCountries
            advancedSearchCountryListViewController.delegate = self
            advancedSearchCountryListViewController.simpleNavigationBarView = simpleNavigationBarView

        case let advancedSearchReleaseTypeListViewController as AdvancedSearchReleaseTypeListViewController:
            advancedSearchReleaseTypeListViewController.selectedReleaseTypes = selectedReleaseTypes
            advancedSearchReleaseTypeListViewController.simpleNavigationBarView = simpleNavigationBarView
            advancedSearchReleaseTypeListViewController.delegate = self

        case let advancedSearchReleaseFormatListViewController as AdvancedSearchReleaseFormatListViewController:
            advancedSearchReleaseFormatListViewController.selectedReleaseFormats = selectedReleaseFormats
            advancedSearchReleaseFormatListViewController.simpleNavigationBarView = simpleNavigationBarView
            advancedSearchReleaseFormatListViewController.delegate = self

        case let advancedSearchAlbumsResultsViewController as AdvancedSearchAlbumsResultsViewController:
            if let optionsList = sender as? String {
                advancedSearchAlbumsResultsViewController.optionsList = optionsList
                advancedSearchAlbumsResultsViewController.navigationBar = simpleNavigationBarView
            }

        default:
            break
        }
    }

    private func performSearch() {
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

        //Release title
        optionsList += "releaseTitle="
        if let releaseTitle = releaseTitleTextField.text {
            optionsList += releaseTitle
        }
        optionsList += "&"

        //Exact release match
        let exactReleaseMatch = exactMatchReleaseTitleSwitch.isOn ? 1 : 0
        optionsList += "exactReleaseMatch=\(exactReleaseMatch)&"

        //From year
        optionsList += "releaseYearFrom="
        if let fromYear = selectedFromYear {
            optionsList += "\(fromYear)"
        }
        optionsList += "&"

        //From month
        optionsList += "releaseMonthFrom="
        if let fromMonth = selectedFromMonth {
            optionsList += "\(fromMonth.rawValue)"
        }
        optionsList += "&"

        //To year
        optionsList += "releaseYearTo="
        if let toYear = selectedToYear {
            optionsList += "\(toYear)"
        }
        optionsList += "&"

        //To month
        optionsList += "releaseMonthTo="
        if let toMonth = selectedToMonth {
            optionsList += "\(toMonth.rawValue)"
        }
        optionsList += "&"

        //Country
        switch selectedCountries.count {
        case 0: optionsList += "country=&"
        case 1: optionsList += "country=\(selectedCountries[0].iso)&"
        default: selectedCountries.forEach { optionsList += "country[]=\($0.iso)&" }
        }

        //City, state, province
        optionsList += "location="
        if let cityStateProvince = cityStateProvinceTextField.text {
            optionsList += cityStateProvince
        }
        optionsList += "&"

        //Label
        optionsList += "releaseLabelName="
        if let labelName = labelNameTextField.text {
            optionsList += labelName
        }
        optionsList += "&"

        //Indie label
        let indieLabel = indieLabelSwitch.isOn ? 1 : 0
        optionsList += "indieLabel=\(indieLabel)&"

        //Catalog number
        optionsList += "releaseCatalogNumber="
        if let catalogNumber = catalogNumberTextField.text {
            optionsList += catalogNumber
        }
        optionsList += "&"

        //Identifier
        optionsList += "releaseIdentifiers="
        if let identifier = identifierTextField.text {
            optionsList += identifier
        }
        optionsList += "&"

        //Recording information
        optionsList += "releaseRecordingInfo="
        if let recordingInformation = recordingInformationTextField.text {
            optionsList += recordingInformation
        }
        optionsList += "&"

        //Version description
        optionsList += "releaseDescription="
        if let versionDescription = versionDescriptionTextField.text {
            optionsList += versionDescription
        }
        optionsList += "&"

        //Additional notes
        optionsList += "releaseNotes="
        if let additionalNotes = additionalNotesTextField.text {
            optionsList += additionalNotes
        }
        optionsList += "&"

        //Genre
        optionsList += "genre="
        if let genre = genreTextField.text {
            optionsList += genre
        }
        optionsList += "&"

        //Release type
        selectedReleaseTypes.forEach { optionsList += "releaseType[]=\($0.rawValue)&" }

        //Release format
        selectedReleaseFormats.forEach { optionsList += "releaseFormat[]=\($0.parameter)&" }

        performSegue(withIdentifier: "ShowResult", sender: optionsList)

        Analytics.logEvent("perform_advanced_search_albums", parameters: nil)
    }
}

// MARK: - UIPickerView as keyboard for year month picker
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

            let buttonSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            //swiftlint:disable:next line_length
            let buttonDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(Self.doneAction))
            buttonDone.tintColor = Settings.currentTheme.titleColor
            toolbar.items = [buttonSpace, buttonDone]
            toolbar.isUserInteractionEnabled = true
            return toolbar
        }

        fromYearMonthPickerView = pickerView()
        toYearMonthPickerView = pickerView()

        fromYearMonthTextField.inputView = fromYearMonthPickerView
        fromYearMonthTextField.inputAccessoryView = toolbarWithDoneButton()
        fromYearMonthTextField.delegate = self

        toYearMonthTextField.inputView = toYearMonthPickerView
        toYearMonthTextField.inputAccessoryView = toolbarWithDoneButton()
        toYearMonthTextField.delegate = self
    }

    @objc
    private func doneAction() { view.endEditing(true) }

    private func initYearsList() {
        yearsList = []
        for year in 0...thisYear - minimumYearOfFormation {
            yearsList.append(thisYear - year)
        }
    }

    private func updateFromYearMonthTextFieldText() {
        //Year can not be nil
        if let selectedFromYear = selectedFromYear {
            if let selectedFromMonth = selectedFromMonth {
                fromYearMonthTextField.text = "\(selectedFromMonth.shortForm) \(selectedFromYear)"
            } else {
                fromYearMonthTextField.text = "\(selectedFromYear)"
            }
        } else {
            fromYearMonthTextField.text = nil
        }
    }

    private func updateToYearMonthTextFieldText() {
        if let selectedToYear = selectedToYear {
            if let selectedToMonth = selectedToMonth {
                toYearMonthTextField.text = "\(selectedToMonth.shortForm) \(selectedToYear)"
            } else {
                toYearMonthTextField.text = "\(selectedToYear)"
            }
        } else {
            toYearMonthTextField.text = nil
        }
    }
}

// MARK: - UITableViewDelegate
extension AdvancedSearchAlbumsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AdvancedSearchAlbumsViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case fromYearMonthTextField: selectedFromYear = nil; selectedFromMonth = nil
        case toYearMonthTextField: selectedToYear = nil; selectedToMonth = nil
        default: break
        }
        return true
    }
}

// MARK: - UIPickerViewDelegate
extension AdvancedSearchAlbumsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case fromYearMonthPickerView:
            if component == 0 {
                selectedFromMonth = Month.allCases[row]
            } else {
                selectedFromYear = yearsList[row]
            }
            updateFromYearMonthTextFieldText()

        case toYearMonthPickerView:
            if component == 0 {
                selectedToMonth = Month.allCases[row]
            } else {
                selectedToYear = yearsList[row]
            }
            updateToYearMonthTextFieldText()

        default: return
        }
        Analytics.logEvent("change_advanced_search_option", parameters: ["option": "Year/month"])
    }
}

// MARK: - UIPickerViewDataSource
extension AdvancedSearchAlbumsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return Month.allCases.count
        case 1: return yearsList.count
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            let month = Month.allCases[row]
            return month.longForm
        case 1:
            let year = yearsList[row]
            return "\(year)"
        default: return nil
        }
    }
}

// MARK: - AdvancedSearchCountryListViewControllerDelegate
extension AdvancedSearchAlbumsViewController: AdvancedSearchCountryListViewControllerDelegate {
    func didUpdateSelectedCountries(_ selectedCountries: [Country]) {
        self.selectedCountries = selectedCountries
        updateCountryListLabel()
        tableView.reloadData()
        Analytics.logEvent("change_advanced_search_option", parameters: ["option": "Countries list"])
    }

    private func generateSelectedCoutriesString() -> String {
        if selectedCountries.isEmpty {
            return "Any country"
        } else {
            var countriesName: String = ""
            for (index, country) in selectedCountries.enumerated() {
                if index == selectedCountries.count - 1 {
                    countriesName.append("\(country.name)")
                } else {
                    countriesName.append("\(country.name), ")
                }
            }
            return countriesName
        }
    }
}

// MARK: - AdvancedSearchReleaseTypeListViewControllerDelegate
extension AdvancedSearchAlbumsViewController: AdvancedSearchReleaseTypeListViewControllerDelegate {
    func didUpdateSelectedReleaseTypes(_ releaseTypes: [ReleaseType]) {
        selectedReleaseTypes = releaseTypes
        updateReleaseTypeLabel()
        tableView.reloadData()
        Analytics.logEvent("change_advanced_search_option", parameters: ["option": "Release types"])
    }

    private func generateSelectedReleaseTypeString() -> String {
        if selectedReleaseTypes.isEmpty || selectedReleaseTypes.count == ReleaseType.allCases.count {
            return "Any"
        } else {
            var releasesName: String = ""
            for (index, releaseType) in selectedReleaseTypes.enumerated() {
                if index == selectedReleaseTypes.count - 1 {
                    releasesName.append("\(releaseType.description)")
                } else {
                    releasesName.append("\(releaseType.description), ")
                }
            }
            return releasesName
        }
    }
}

// MARK: - AdvancedSearchReleaseFormatListViewControllerDelegate
extension AdvancedSearchAlbumsViewController: AdvancedSearchReleaseFormatListViewControllerDelegate {
    func didUpdateSelectedReleaseFormats(_ releaseFormats: [ReleaseFormat]) {
        selectedReleaseFormats = releaseFormats
        updateReleaseFormatLabel()
        tableView.reloadData()
        Analytics.logEvent("change_advanced_search_option", parameters: ["option": "Release formats"])
    }

    private func generateSelectedReleaseFormatString() -> String {
        if selectedReleaseFormats.isEmpty || selectedReleaseFormats.count == ReleaseFormat.allCases.count {
            return "Any"
        } else {
            var releasesFormat: String = ""
            for (index, releaseFormat) in selectedReleaseFormats.enumerated() {
                if index == selectedReleaseFormats.count - 1 {
                    releasesFormat.append("\(releaseFormat.description)")
                } else {
                    releasesFormat.append("\(releaseFormat.description), ")
                }
            }
            return releasesFormat
        }
    }
}
