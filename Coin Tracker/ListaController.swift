//
//  ListaController.swift
//  Coin Tracker
//
//  Created by Rinor Bytyci on 11/12/17.
//  Copyright © 2017 Appbites. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage


//Duhet te jete conform protocoleve per tabele
class ListaController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    
    @IBOutlet weak var tableView: UITableView!
    
    //Krijo IBOutlet tableView nga View
    //Krijo nje varg qe mban te dhena te tipit CoinCellModel
    var allCoins:[CoinCellModel] = [CoinCellModel]()
    
    //Krijo nje variable slectedCoin te tipit CoinCellModel!
    var selectedCoin:CoinCellModel?
    
    //kjo perdoret per tja derguar Controllerit "DetailsController"
    //me poshte, kur ndodh kalimi nga screen ne screen (prepare for segue)
    
    
    //URL per API qe ka listen me te gjithe coins
    //per me shume detaje : https://www.cryptocompare.com/api/
    let APIURL = "https://min-api.cryptocompare.com/data/all/coinlist"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appdelegate.persistentContainer.viewContext
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        //regjistro delegate dhe datasource per tableview
        //regjistro custom cell qe eshte krijuar me NIB name dhe
        //reuse identifier
        
        
        //Thirr funksionin getDataFromAPI()
        getDataFromAPI()
    }
    
    //Funksioni getDataFromAPI()
    //Perdor alamofire per te thirre APIURL dhe ruan te dhenat
    //ne listen vargun me CoinCellModel
    //Si perfundim, thrret tableView.reloadData()
    func getDataFromAPI(){
        
        Alamofire.request(APIURL).responseData{(data) in
            if data.result.isSuccess {
                let coinData = JSON(data.result.value!)
                
                for(key, value): (String, JSON) in coinData["Data"]{
                   
                    let coin = CoinCellModel(coinName: value["CoinName"].stringValue, coinSymbol: value["Name"].stringValue, coinAlgo: value["Alogrithm"].stringValue, totalSuppy: value["TotalCoinSupply"].stringValue, imagePath: value["ImageUrl"].stringValue)
                    self.allCoins.append(coin)
                }
                
                self.tableView.reloadData()
            }
            
        }
            
           
    }
    
    //Shkruaj dy funksionet e tabeles ketu
    //cellforrowat indexpath dhe numberofrowsinsection
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCoin = allCoins[indexPath.row]
        performSegue(withIdentifier: "shfaqDetajet", sender: self)
    }
    
   
    //Funksioni didSelectRowAt indexPath merr parane qe eshte klikuar
    //Ruaj Coinin e klikuar tek selectedCoin variabla e deklarurar ne fillim
    //dhe e hap screenin tjeter duke perdore funksionin
    //performSeguew(withIdentifier: "EmriILidhjes", sender, self)
    
    
    //Beje override funksionin prepare(for segue...)
    //nese identifier eshte emri i lidhjes ne Storyboard.
    //controllerit tjeter ja vendosim si selectedCoin, coinin
    //qe e kemi ruajtur me siper
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shfaqDetajet" {
            let destination = segue.destination as! DetailsController
            destination.selectedCoin = selectedCoin
        }
    }
   

}
