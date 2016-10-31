//
//  ViewController.swift
//  Weather Report
//
//  Created by Jeremy Conley on 9/21/16.
//  Copyright © 2016 JeremyConley. All rights reserved.
//

import UIKit
import Canvas

class ViewController: UIViewController {
    
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var highTempLbl: UILabel!
    @IBOutlet weak var lowTempLbl: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var conditionPic: UIImageView!
    @IBOutlet weak var animationView: CSAnimationView!
    @IBOutlet weak var searchAnimView: CSAnimationView!
    @IBOutlet weak var searchButton: UIButton!
    
    var cloudImage: UIImage?
    var clearImage: UIImage?
    var rainyImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        cloudImage = UIImage(named: "Cloudy.png")
        clearImage = UIImage(named: "Sunny.png")
        rainyImage = UIImage(named: "Rain.png")
        searchButton.layer.cornerRadius = 10
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func SearchCity(_ sender: AnyObject) {
        getWeather("http://api.openweathermap.org/data/2.5/weather?q=" + cityText.text!.replacingOccurrences(of: " ", with: "+") + "&appid=2854c5771899ff92cd962dd7ad58e7b0")

        //Conditions
            //"Clear"
            //"Rain"
            //"Clouds"
        
        searchAnimView.type = "morph"
        searchAnimView.startCanvasAnimation()
    }
    
    func animateView(){
        let animDirection = Int(arc4random_uniform(2))
        if animDirection == 0 {
            animationView.type = "bounceLeft"
            animationView.startCanvasAnimation()
        } else {
            animationView.type = "bounceRight"
            animationView.startCanvasAnimation()
        }
        
    }
    
    func showError(){
        let alert = UIAlertController(title: "Oops!", message: "Can't find weather for " + cityText.text!, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWeather(_ url: String){
        let webUrl = URL(string: url)
        let task = URLSession.shared.dataTask(with: webUrl!, completionHandler: { (data, response, error) in
            if let content = data {
                //data is not null
                DispatchQueue.main.async(execute: { 
                    //do something with data
                    self.processData(content)
                })
            } else {
                //data is null
                print("nahhhhh")
                
            }
        }) 
        task.resume()
    }
    
    
    func processData(_ data: Data){
        var json: NSDictionary!
        var currentTemp: Int?
        var minTemp: Int?
        var maxTemp: Int?
        
        do {
            //Convert data to JSON
            json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as! NSDictionary
            //Get main Data
            //Get city name
            if let name = json["name"]{
                cityName.text = name as! String
            }
            if let main = json["main"] as? NSDictionary{
                //Get current temp
                if let temp = main["temp"]{
                    let curTemp = temp as? Double
                    let newTemp = kelvinToFar(curTemp!)
                    let intTemp = round(newTemp)
                    currentTemp = doubleToInt(intTemp)
                    currentTempLbl.text = String(currentTemp!) + "º"
                    print(currentTemp)
                }
                //Get min temp
                if let mintemp = main["temp_min"] as? Double{
                    let min = mintemp as? Double
                    let newTemp = kelvinToFar(min!)
                    let intTemp = round(newTemp)
                    minTemp = doubleToInt(intTemp)
                    lowTempLbl.text = String(minTemp!) + "º"
                    print(minTemp)
                    
                }
                //Get max temp
                if let maxtemp = main["temp_max"] as? Double{
                    let max = maxtemp as? Double
                    let newTemp = kelvinToFar(max!)
                    let intTemp = round(newTemp)
                    maxTemp = doubleToInt(intTemp)
                    highTempLbl.text = String(maxTemp!) + "º"
                    print(maxTemp)
                    
                }
            } else {
                showError()
            }
            //Get current Condition
            if let weather = json["weather"] as? [NSDictionary]{
                print(weather)
                if let condition = weather[0]["main"] as? String{
                    let conditionTxt = condition
                    weatherCondition.text = conditionTxt
                    setConditionImage(conditionTxt)
                }// else {
                //    print ("nahhhhhh")
                //}
            }
            
            
        } catch let error as NSError {
            print("herrrrrrrr")
        }
        
       
    }
    
    func kelvinToFar(_ temp: Double) -> Double{
        return (temp*9/5) - 459.67
    }
    
    func doubleToInt(_ temp: Double) -> Int {
        return Int(temp)
        
    }
    
    func setConditionImage(_ condition: String){
        animateView()
        if condition == "Clear"{
            conditionPic.image = clearImage
        } else if condition == "Rain"{
            conditionPic.image = rainyImage
        } else if condition == "Clouds"{
            conditionPic.image = cloudImage
        } else {
            
        }
    }


}

