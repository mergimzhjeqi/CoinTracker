//
//  ViewController.swift
//  Coin Tracker
//
//  Created by Rinor Bytyci on 11/12/17.
//  Copyright © 2017 Appbites. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import CoreData

class DetailsController: UIViewController {

    //selectedCoin deklaruar me poshte mbushet me te dhena nga
    //controlleri qe e thrret kete screen (Shiko ListaController.swift)
    var selectedCoin:CoinCellModel!
    
    var eshteERuajtur: Bool = false
    
    //IBOutlsets jane deklaruar me poshte
    @IBOutlet weak var imgFotoja: UIImageView!
    @IBOutlet weak var lblDitaOpen: UILabel!
    @IBOutlet weak var lblDitaHigh: UILabel!
    @IBOutlet weak var lblDitaLow: UILabel!
    @IBOutlet weak var lbl24OreOpen: UILabel!
    @IBOutlet weak var lbl24OreHigh: UILabel!
    @IBOutlet weak var lbl24OreLow: UILabel!
    @IBOutlet weak var lblMarketCap: UILabel!
    @IBOutlet weak var lblCmimiBTC: UILabel!
    @IBOutlet weak var lblCmimiEUR: UILabel!
    @IBOutlet weak var lblCmimiUSD: UILabel!
    @IBOutlet weak var lblCoinName: UILabel!
    
    //APIURL per te marre te dhenat te detajume per coin
    //shiko: https://www.cryptocompare.com/api/ per detaje
    let APIURL = "https://min-api.cryptocompare.com/data/pricemultifull"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //brenda ketij funksioni, vendosja foton imgFotoja Outletit
        //duke perdorur AlamoFireImage dhe funksionin:
        //af_setImage(withURL:URL)
        //psh: imgFotoja.af_setImage(withURL: URL(string: selectedCoin.imagePath)!)
        //Te dhenat gjenerale per coin te mirren nga objeti selectedCoin
        lblCoinName.text = selectedCoin.coinName
        imgFotoja.af_setImage(withURL: URL(string: selectedCoin.coinImage())!)
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favoritet")
        request.predicate = NSPredicate(format: "coinSymbol = %@", selectedCoin.coinSymbol)
        request.returnsObjectsAsFaults = false
        do {
            let rezultati = try context.fetch(request)
            if rezultati.count > 0 {
                eshteERuajtur = true
            }
           
        }
        catch{
            print("Gabim")
        }
        
        
        
        //Krijo nje dictionary params[String:String] per ta thirrur API-ne
        //parametrat qe duhet te jene ne kete params:
        //fsyms - Simboli i Coinit (merre nga selectedCoin.coinSymbol)
        //tsyms - llojet e parave qe na duhen: ""BTC,USD,EUR""
        var params: [String: String] = ["fsyms" : selectedCoin.coinSymbol, "tsyms" : "BTC,USD,EUR"]
        //Thirr funksionin getDetails me parametrat me siper
        
        getDetails(params: params)
    }

    func getDetails(params:[String:String]){
        
        
        //Thrret Alamofire me parametrat qe i jan jap funksionit
        //dhe te dhenat qe kthehen nga API te mbushin labelat
        //dhe pjeset tjera te view
        
        Alamofire.request(APIURL, method: .get, parameters: params).responseData { (data) in
            if data.result.isSuccess {
                
                let coinDetail = JSON(data.result.value!)
                print(coinDetail)
                let coin = CoinDetailsModel(marketCap: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["USD"]["MKTCAP"].stringValue, hourHigh: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["BTC"]["HIGH24HOUR"].stringValue, hourLow: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["BTC"]["LOW24HOUR"].stringValue, hourOpen: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["BTC"]["OPEN24HOUR"].stringValue, dayHigh: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["BTC"]["HIGHDAY"].stringValue, dayLow: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["BTC"]["LOWDAY"].stringValue, dayOpen: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["BTC"]["OPENDAY"].stringValue, priceEUR: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["EUR"]["PRICE"].stringValue, priceUSD: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["USD"]["PRICE"].stringValue, priceBTC: coinDetail["DISPLAY"][self.selectedCoin.coinSymbol]["BTC"]["PRICE"].stringValue)
                
                self.updateUI(coin: coin)
                
            }
        }
        
        
    }
    
    func updateUI(coin: CoinDetailsModel){
        
        lblDitaLow.text = coin.dayLow
        lblDitaOpen.text = coin.dayOpen
        lblDitaHigh.text = coin.dayHigh
        lbl24OreLow.text = coin.hourLow
        lbl24OreHigh.text = coin.hourHigh
        lbl24OreOpen.text = coin.hourOpen
        lblCmimiBTC.text = coin.priceBTC
        lblCmimiEUR.text = coin.priceEUR
        lblCmimiUSD.text = coin.priceUSD
        lblMarketCap.text = coin.marketCap
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //IBAction mbylle - per butonin te gjitha qe mbyll ekranin
   
    @IBAction func teGjitha(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnRuajTeFavoritet(_ sender: Any) {
        
        if  eshteERuajtur{
            
            
            let alertController = UIAlertController(title: "Coin-i eshte i ruajtur", message: "Ky coin ekziston \(selectedCoin.coinName)", preferredStyle: .alert)
            
            //Krijojme aksionin (butonin) qe vetem do e fsheh alert controllerin
            let alertAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            //Aksionin e shtojme ne Alert Controllerin tone
            alertController.addAction(alertAction)
            
            //I thojme pamjes qe te shfaqe controllerin
            present(alertController, animated: true, completion: nil)
        }else{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appdelegate.persistentContainer.viewContext
            
            let favoriteCoin = NSEntityDescription.insertNewObject(forEntityName: "Favoritet", into: context)
            
            favoriteCoin.setValue(selectedCoin.totalSuppy, forKey: "totalSupply")
            favoriteCoin.setValue(selectedCoin.coinSymbol, forKey: "coinSymbol")
            favoriteCoin.setValue(selectedCoin.coinName, forKey: "coinName")
            favoriteCoin.setValue(selectedCoin.coinAlgo, forKey: "coinAlgo")
            favoriteCoin.setValue(selectedCoin.imagePath, forKey: "imagePath")
            
            
            do {
                try context.save()
                eshteERuajtur = true
            } catch  {
                print("Gabim gjate ruajtjes.")
            }
            
            
            let alertController = UIAlertController(title: "Shto nje coin", message: "Coin-i i shtuar \(selectedCoin.coinName)", preferredStyle: .alert)
            
            //Krijojme aksionin (butonin) qe vetem do e fsheh alert controllerin
            let alertAction = UIAlertAction(title: "Ne Rregull", style: .default, handler: nil)
            
            //Aksionin e shtojme ne Alert Controllerin tone
            alertController.addAction(alertAction)
            
            //I thojme pamjes qe te shfaqe controllerin
            present(alertController, animated: true, completion: nil)
        }
       
    }
    

}

