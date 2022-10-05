//
//  NewPlaceViewController.swift
//  My Places
//
//  Created by Roma Bogatchuk on 28.09.2022.
//

import UIKit
import PhotosUI

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
  
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        saveButton.isEnabled = false
        //наблюдатель за полем placeName
        placeName.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        setupEditScreen()
    }

    // MARK: Text View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")
            
            let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImage()
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImage(.camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertSheet.addAction(photo)
            alertSheet.addAction(camera)
            alertSheet.addAction(cancel)
            
            present(alertSheet, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
    
    func savePlace(){
        
       
        
        var image: UIImage?
        if imageIsChanged  {
            image = placeImage.image
        } else {
            image = UIImage(named: "imagePlaceholder")
        }
        let imageData = image?.jpegData(compressionQuality: 0.5)//преобразование и сжатие файла
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        
        if currentPlace != nil{
            try! realm.write{
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        }else {
            StorageManager.saveObject(newPlace)
        }
        
    }
    
    private func setupEditScreen(){
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let imageData = UIImage(data: data) else {return}
            
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            placeImage.image = imageData
            placeImage.contentMode = .scaleAspectFill
            ratingControl.rating = Int(currentPlace.rating)
            
        }
    }
    
    private func setupNavigationBar(){
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
        
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

// MARK: Text Field Delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    //скрываем клавиатуру при нажатии на Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChange(){
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
}

extension NewPlaceViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for item in results {
            
            item.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                                        self.placeImage.image = image
                                        self.placeImage.contentMode = .scaleAspectFill
                                        self.placeImage.clipsToBounds = true
                                        self.imageIsChanged = true
                                    }
                    
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFit
        placeImage.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
    }
    
    func chooseImage(){
        var configuranion = PHPickerConfiguration()
        configuranion.filter = PHPickerFilter.images
        configuranion.selectionLimit = 1
        configuranion.preferredAssetRepresentationMode = .automatic
        let picker = PHPickerViewController(configuration: configuranion)
        picker.delegate = self
        present(picker, animated: true)
        
        
    }
    func chooseImage(_ source: UIImagePickerController.SourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
            
        }
        
    }
}
