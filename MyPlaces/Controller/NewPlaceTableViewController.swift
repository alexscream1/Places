//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Alexey Onoprienko on 04.03.2021.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

    var currentPlace : PlaceModel?
    var imageIsChanged = false
    
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var addPlaceImageView: UIImageView!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonItem.isEnabled = false
        placeTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    
    private func setupEditScreen() {
        
        if currentPlace != nil {
            setupNavBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            
            addPlaceImageView.image = image
            addPlaceImageView.contentMode = .scaleAspectFill
            placeTextField.text = currentPlace?.name
            countryTextField.text = currentPlace?.country
            locationTextField.text = currentPlace?.location
            
            if let rating = currentPlace?.rating {
                ratingControl.rating = Int(rating)
            }
            
        }
        
    }
    
    private func setupNavBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        navigationItem.leftBarButtonItem = .none
        title = currentPlace?.name
        saveButtonItem.isEnabled = true
        
    }

    // MARK: - Save place function
    func savePlace() {
        
        let image = imageIsChanged ? addPlaceImageView.image : #imageLiteral(resourceName: "travel")
        
        let imageData = image?.pngData()
        
        let newPlace = PlaceModel(name: placeTextField.text!, country: countryTextField.text, city: locationTextField.text, imageData: imageData, rating: Double(ratingControl.rating))
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.country = newPlace.country
                currentPlace?.location = newPlace.location
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    // MARK: - Cancel Button Action
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let imageIcon = #imageLiteral(resourceName: "image")
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(imageIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
           
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(camera)
            alert.addAction(photo)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let mapVC = segue.destination as? MapViewController else {return}
        
        mapVC.receivedSegueIdentifier = identifier
        
        // Assign delegate for mapVCDelegate
        mapVC.mapVCDelegate = self
        
        if identifier == "showPlace" {
            mapVC.place.name = placeTextField.text!
            mapVC.place.country = countryTextField.text!
            mapVC.place.location = locationTextField.text!
            mapVC.place.imageData = addPlaceImageView.image?.pngData()
        }
        
        
    }
    
    
}

// MARK: - Textfield delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Save button enable/disable
    @objc private func textFieldChanged() {
        if placeTextField.text?.isEmpty == false {
            saveButtonItem.isEnabled = true
        } else {
            saveButtonItem.isEnabled = false
        }
    }
}

// MARK: - Function to make picture or add image

extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
        
    }
    
    // MARK: - Save picture to NewPlaceTableViewController
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        addPlaceImageView.image = info[.editedImage] as? UIImage
        addPlaceImageView.contentMode = .scaleAspectFill
        addPlaceImageView.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - MapViewControllerDelegate

extension NewPlaceTableViewController: MapViewControllerDelegate {
    
    func getAddress(_ address: String?) {
        locationTextField.text = address
    }
}
