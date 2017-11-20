//
//  FavoritetController.swift
//  Coin Tracker
//
//  Created by Rinor Bytyci on 11/13/17.
//  Copyright © 2017 Appbites. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import CoreData


//Klasa permbane tabele kshtuqe duhet te kete
//edhe protocolet per tabela
class FavoritetController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    @IBOutlet weak var tableView: UITableView!
    
    var allCoins:[CoinCellModel] = [CoinCellModel]()
    
    var selectedCoin:CoinCellModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appdelegate.persistentContainer.viewContext
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        
        //Lexo nga CoreData te dhenat dhe ruaj me nje varg
        //qe duhet deklaruar mbi funksionin UIViewController
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favoritet")
        
        request.returnsObjectsAsFaults = false
        
        
        
        do {
            let rezultati = try context.fetch(request)
            
            if rezultati.count > 0 {
                for item in rezultati as! [NSManagedObject]{
                    
                    let coin = CoinCellModel(coinName: item.value(forKey: "coinName") as! String, coinSymbol: item.value(forKey: "coinSymbol") as! String, coinAlgo: item.value(forKey: "coinAlgo") as! String, totalSuppy: item.value(forKey: "totalSupply") as! String, imagePath: item.value(forKey: "imagePath") as! String)
                    
                    self.allCoins.append(coin)
                }
                
                tableView.reloadData()
            }
            else{
                print("Nuk ka elemente")
            }
            
        } catch  {
            print("Gabim gjate leximit")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCoins.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell") as! CoinCell
        
        
        cell.lblEmri.text = allCoins[indexPath.row].coinName
        cell.lblTotali.text = allCoins[indexPath.row].totalSuppy
        cell.lblSymboli.text = allCoins[indexPath.row].coinSymbol
        cell.lblAlgoritmi.text = allCoins[indexPath.row].coinAlgo
        cell.imgFotoja.af_setImage(withURL: URL(string: allCoins[indexPath.row].coinImage())!)
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fshijCoins(symboli: allCoins[indexPath.row].coinSymbol)
            print("Deleted")
            
            
            self.allCoins.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func fshijCoins(symboli: String) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favoritet")
        request.predicate = NSPredicate(format: "coinSymbol = %@", symboli)
        request.returnsObjectsAsFaults = false
        do {
            let rezultati = try context.fetch(request)
            
            for items in rezultati as! [NSManagedObject]{
                
                
               
                context.delete(items)
                
                do {
                    try context.save()
                }catch{
                    print("Gabim gjate fshirjes")
                }
                
            }
        }
        catch{
            print("Gabim")
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnKthehu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCoin = allCoins[indexPath.row]
        performSegue(withIdentifier: "shfaqDetajet", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shfaqDetajet" {
            let destination = segue.destination as! DetailsController
            destination.selectedCoin = selectedCoin
        }
    }
    
}
