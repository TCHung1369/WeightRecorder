//
//  DataTableViewController.swift
//  WeightRecorder
//
//  Created by Tzu_Chen on 26/10/16.
//  Copyright © 2016 Tzu-Chen. All rights reserved.
//

import UIKit
import CoreData
import Social

class DataTableViewController: UITableViewController,NSFetchRequestResult,NSFetchedResultsControllerDelegate {

    
    let coreDataHelper = CoreDataHelper()
    var fetchResultController : NSFetchedResultsController<WeightData>?
    var weightDatas : [WeightData] = []
    let dateFomatter = DateFormatter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest<WeightData>(entityName: "WeightRecord")
        let sortDescription = NSSortDescriptor(key: "dateData", ascending: false)
        fetchRequest.sortDescriptors = [sortDescription]
        //let moc = self.appDelegate.persistentContainer.viewContext
        let moc = self.coreDataHelper.moc
        self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchResultController?.delegate = self
        
        do{
            try self.fetchResultController?.performFetch()
            self.weightDatas = self.fetchResultController?.fetchedObjects as [WeightData]!
            
        }catch{print(error)}
        
        self.dateFomatter.dateFormat = "yyyy-MM-dd"

        
    }
    
    @IBAction func exitButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.weightDatas.count == 0 {
            return 0
        }else{
            return self.weightDatas.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! CustomTableViewCell
        
        cell.cellFatRate.text = String(self.weightDatas[indexPath.row].fatRate)
        cell.cellWeight.text = String(self.weightDatas[indexPath.row].weight)
        cell.cellImageView.image = UIImage(data: self.weightDatas[indexPath.row].image)
       //let transform = CGAffineTransform.init(rotationAngle: CGFloat(90.0 * M_PI / 180.0))
       //cell.cellImageView.transform = transform
        cell.cellDate.text = self.dateFomatter.string(from: self.weightDatas[indexPath.row].dateData)
        return cell
    }
    
    
    //Mark: - TableAction
   override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
    
    
    let shareAction = UITableViewRowAction(style: .default, title: "分享") { (rowAction, indexPath) in
        
        
      let defaultText = "來看看我的體重記錄吧@WeightReocrder App"
      let shareActionController = UIAlertController(title: nil
        , message: "請選擇", preferredStyle: .actionSheet)
    
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: {(action) -> Void in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
                
             let tweetComposer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
              tweetComposer?.setInitialText(defaultText)
              tweetComposer?.add(UIImage(data: self.weightDatas[indexPath.row].image))
              self.present(tweetComposer!, animated: true
                , completion: nil)
            }else{
             let alertController = UIAlertController(title: "Twitter 沒有登入歐", message: "請到setting -> Twitter開啟您的帳號歐", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
        
        
        let faceBookAction = UIAlertAction(title: "FaceBook", style: .default, handler:{(action)-> Void in
         
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
                
                let faceBookComposer = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                faceBookComposer?.setInitialText(defaultText)
                faceBookComposer?.add(UIImage(data: self.weightDatas[indexPath.row].image))
                self.present(faceBookComposer!, animated: true
                    , completion: nil)
            }else{
                let alertController = UIAlertController(title: "FaceBook 沒有登入歐", message: "請到setting -> FaceBook開啟您的帳號歐", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
            }

        
        
        
        
        
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    shareActionController.addAction(twitterAction)
    shareActionController.addAction(faceBookAction)
    shareActionController.addAction(cancelAction)
    self.present(shareActionController, animated: true, completion: nil)
    
    }
    
    
    
    
     let tableViewRowAction = UITableViewRowAction(style: .default, title: "刪除") { (rowAction, indexPath) in
        
        let alertController = UIAlertController(title: "注意", message: "您是否確定要刪除這個資料?", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "確定", style: .default, handler: { (alertaction) in
            let moc = self.coreDataHelper.moc!
            let deleteWeightData = self.fetchResultController?.object(at: indexPath) as WeightData!
            
            moc.delete(deleteWeightData!)
            
            self.coreDataHelper.saveContext()
  
        })
        
        let alertAction2 = UIAlertAction(title: "取消", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        alertController.addAction(alertAction2)
        
        self.present(alertController, animated: true, completion: nil)
        }
    
    
    
    
    tableViewRowAction.backgroundColor = UIColor.red
    shareAction.backgroundColor = UIColor.blue
        return [tableViewRowAction,shareAction]
    }
    
}



extension DataTableViewController{

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
      self.tableView.beginUpdates()
    }

    
    @objc(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
    
        switch type {
        case .delete:
            if let indexPath = indexPath{
             self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .insert :
            if let newIndexPath = newIndexPath{
            self.tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let newIndexPath = newIndexPath{
             self.tableView.reloadRows(at: [newIndexPath], with: .fade)
            }
        default:
            self.tableView.reloadData()
        }
        self.weightDatas = self.fetchResultController?.fetchedObjects as [WeightData]!
        
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
     self.tableView.endUpdates()
    }
}
