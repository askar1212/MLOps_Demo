pipeline {
    agent any
	
    stages{
        stage(Initial){
 	        steps{
		        sh '   sudo cp -r -v -f * /home/ec2-user '   
 	        }
 	    }
	    stage(Imagecreation){
            steps{
                sh ''' if sudo docker image ls | grep mlops-demo
                       then 
                            sudo echo "Docker Image mlops-demo already exists"
                        else
                            sudo docker  build -t  mlops-demo  /home/ec2-user/ 
                        fi     '''       
			}
        } 
        stage(Training){
 	        steps{
		        sh '''  sudo docker run -p 5000:5000 -i -v /home/ec2-user:/root/  mlops-demo python3 diabetes.py > result.txt
		                
					    sudo cat result.txt  '''
				
                				
		   }
		}
       stage(Evaluation){
            steps{
			    script{
				
                    this.result = sh(script: "sudo cat result.txt", returnStdout: true)
	            echo "not trimmed ${this.resultNotTrim}"
                    int res="${result}"    
                    if ( 90 >= res ){
					
                            echo "Model accuracy is below 90 need to retrain the model for better accuracy"
							emailext ( attachLog: false, body: """<p> Model accuracy is below 90 need to retrain the model for better accuracy, </p>
                            <p> please go to the Jenkins URL and check: ${env.BUILD_URL} </p>""",
                            mimeType: "text/html", 
                            compressLog: true, 
                            recipientProviders: [buildUser(), culprits(), developers(), brokenBuildSuspects(), brokenTestsSuspects(), upstreamDevelopers(), requestor()],  
                            subject: """Model Retraining Needed - ${env.JOB_NAME}""", 
                            to: 'mohammed.a@cloudifyops.com')
                        }			           
                    else { 
                            echo "Model accuracy is above 90 and model is ready for deployment"
                    }
				}	
           }
        }
		stage(Deploy){
            steps{
			    script{ 
				    int res="${result}"
                    if ( 90 >= res ){	
                        echo "Model accuracy is below 90 need to retrain the model for better accuracy"
						}
				    else
						{    
			            sh ' sudo docker run -p 5000:5000  -d -i  -v /home/ec2-user:/root/  mlops-demo python3 diab_app.py '
					    env.model=sh(script:  "curl -s ifconfig.me", returnStdout: true)              
                        emailext ( attachLog: false, body: """<p> Model achieved desired accuracy, Is being deployed at  http://${env.model}:5000/  - </p>
                        <p> Model Accuracy = ${this.result} </p>""",
                        mimeType: "text/html", 
                        compressLog: true, 
                        recipientProviders: [buildUser(), culprits(), developers(), brokenBuildSuspects(), brokenTestsSuspects(), upstreamDevelopers(), requestor()],  
                        subject: """Model Deployed - ${env.JOB_NAME}""", 
                        to: 'mohammed.a@cloudifyops.com')
                       } 
                
        
		        } 
           }
        }
	}
}
