//
//  DataViewController.swift
//  WeightRecorder
//
//  Created by Tzu_Chen on 19/10/16.
//  Copyright © 2016 Tzu-Chen. All rights reserved.
//

import UIKit
import  CoreData


class DataViewController: UIViewController,UICollectionViewDataSource,NSFetchedResultsControllerDelegate,NSFetchRequestResult,UICollectionViewDelegate {

    var gradientLayer : CAGradientLayer?

    @IBOutlet var myColloectionView : UICollectionView!
    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dateFomatter = DateFormatter()
    let dateData = Date()
    var fetchResultController : NSFetchedResultsController<WeightData>?
    var weightDatas : [WeightData] = []
    var blockOperations:[BlockOperation] = []
    var coreDataHelper = CoreDataHelper()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        self.myColloectionView.layer.cornerRadius = 10
        self.myColloectionView.layer.masksToBounds = true
        
        let fetchRequest = NSFetchRequest<WeightData>(entityName: "WeightRecord")
        let sortDescription = NSSortDescriptor(key: "dateData", ascending: false)
        fetchRequest.sortDescriptors = [sortDescription]
        let moc = self.appDelegate.persistentContainer.viewContext
        
        self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchResultController?.delegate = self
        
        do{
        try self.fetchResultController?.performFetch()
            self.weightDatas = self.fetchResultController?.fetchedObjects as [WeightData]!
            
        }catch{print(error)}
        
        self.dateFomatter.dateFormat = "yyyy-MM-dd"
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.weightDatas.count == 0 {
         return 0
        }else{
        return self.weightDatas.count
        }
    }
    

    
    @IBAction func deleteData2(_ sender: UIButton) {
        //print("\(self.deleteData)")
    

        
        let alertController = UIAlertController(title: "注意", message: "您確定要刪掉這條記錄", preferredStyle: .alert)
        
        let alertActionSure = UIAlertAction(title: "確定", style: .default) { (alertAction) in
            let deleteButton = sender
            let buttonPoint : CGPoint = deleteButton.convert(CGPoint.zero, to: self.myColloectionView)
            var cellIndexAtPath : IndexPath = self.myColloectionView.indexPathForItem(at: buttonPoint)!
            print("\(cellIndexAtPath.row)")
            
           let moc = self.appDelegate.persistentContainer.viewContext
           let deleteDataObject = (self.fetchResultController?.object(at: cellIndexAtPath))! as WeightData
            moc.delete(deleteDataObject)
            self.appDelegate.saveContext()
            
        }
        
        let alertActionCancel = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertController.addAction(alertActionSure)
        alertController.addAction(alertActionCancel)
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell1", for: indexPath) as! MyCollectionViewCell
        cell.fatRate.text = String(self.weightDatas[indexPath.row].fatRate)
        cell.myBMI.text = String(self.weightDatas[indexPath.row].bmiData)
        cell.myHeight.text = String(self.weightDatas[indexPath.row].height)
        cell.myWeight.text = String(self.weightDatas[indexPath.row].weight)
        cell.myImageView.image = UIImage(data: self.weightDatas[indexPath.row].image)
        //let transform = CGAffineTransform.init(rotationAngle: CGFloat(90.0 * M_PI / 180.0))
        //cell.myImageView.transform = transform
        cell.recordDate.text = self.dateFomatter.string(from: self.weightDatas[indexPath.row].dateData)
        
        return cell
    }

    
}

extension DataViewController{

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
       blockOperations.removeAll(keepingCapacity: false)
    }

    @objc(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        
        switch type {
        case .insert:
         blockOperations.append(BlockOperation(block: {
            [weak self] in
            if let this = self{
            this.myColloectionView.insertItems(at: [newIndexPath!])
            }
         })
            )
        
        case .delete:
            print("delete")
            blockOperations.append(BlockOperation(block: {
                [weak self] in
                if let this = self{
                    this.myColloectionView.deleteItems(at: [indexPath!])
                }
                })
            )
        case .update:
            blockOperations.append(BlockOperation(block: {
                [weak self] in
                if let this = self{
                    this.myColloectionView.reloadItems(at: [newIndexPath!])
                }
                })
            )
        default:
            blockOperations.append(BlockOperation(block: {
                [weak self] in
                if let this = self{
                    this.myColloectionView.reloadItems(at: [newIndexPath!])
                }
                })
            )
        }

        self.weightDatas = self.fetchResultController?.fetchedObjects as [WeightData]!
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.myColloectionView.performBatchUpdates({ 
            for operationBlock : BlockOperation in self.blockOperations{
             operationBlock.start()
            }
            }) { (finialed) in
                self.blockOperations.removeAll(keepingCapacity: false)
        }
    }

    
   
}


extension DataViewController{

    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
    }



}
