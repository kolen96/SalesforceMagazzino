import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; //non si usa 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import currentUserId from '@salesforce/user/Id';
import { subscribe, unsubscribe, onError}  from 'lightning/empApi';

import serchItem from '@salesforce/apex/homePageMagazzinoApex.retriveItem';
import updateCount from '@salesforce/apex/homePageMagazzinoApex.updateCount';
import userRole from '@salesforce/apex/homePageMagazzinoApex.userRole';

import NAME_FIELD from '@salesforce/schema/Item__c.Name';
import COUNT_FIELD from '@salesforce/schema/Item__c.Count__c';
import CATEGORY_FIELD from '@salesforce/schema/Item__c.Category__c';


const columns = [
    { label: 'Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' },

    { label: 'Count', fieldName: COUNT_FIELD.fieldApiName, type: 'number', initialWidth: 100, cellAttributes: { iconName: { fieldName: 'dynamicIcon' },alignment: 'left'}},

    { label: 'Category', fieldName: CATEGORY_FIELD.fieldApiName, type: 'picklist' },

    { label: 'SubType', fieldName: 'SubType__r.Name', type: 'text' },

    { label: 'Change Count', type: "button", initialWidth: 150, typeAttributes: {
        label: 'Change',
        name: 'Change',
        title: 'Change',
        disabled: false,
        value: 'Change',
        iconPosition: 'center'
    }, cellAttributes: {
        alignment: 'left'
    }}
];

const columnsLead = [
    { label: 'Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' },

    { label: 'Count', fieldName: COUNT_FIELD.fieldApiName, type: 'number', initialWidth: 100, cellAttributes: { iconName: { fieldName: 'dynamicIcon' },alignment: 'left'}},

    { label: 'Category', fieldName: CATEGORY_FIELD.fieldApiName, type: 'picklist' },

    { label: 'SubType', fieldName: 'SubType__r.Name', type: 'text' },

    { label: 'Location', fieldName: 'Location__r.Name', type: 'text' },

    { label: 'Change Count', type: "button", initialWidth: 150, typeAttributes: {
        label: 'Change',
        name: 'Change',
        title: 'Change',
        disabled: false,
        value: 'Change',
        iconPosition: 'center'
    }, cellAttributes: {
        alignment: 'left'
    }}
];

export default class HomePageMagazzino extends NavigationMixin(LightningElement) {

    //datatable variable
    @track finalSubType = [];
    @track error
    userid = currentUserId

    @track columns 
   
    @track isModalOpen = false 
    error;

    isFiltering = false;

    //copiato serve per l'aggiornamento dinmico
    @api recordId;
    @track createdRecord = false;
    @track isLoading = false;
    subscription = {}
    CHANNEL_NAME = '/event/Refresh_Item_Event__e'

    //
    @track queryTerm = '' 
    errorMsg = ''
    textValue

    recId
    @track count
    @track isButtonDisabled = false

    //in stock filter variable
    @track clearState = true
    @track warningState = true
    @track successState = true
    status = '123'

    //infinity scroll variable
    offset = 0
    targetDatatable = null
    totalNumberOfRows = 20
    resultQ

    countSuccess = 'In Stock'
    
    @track isInfEnabled = true


    async chooseColumn() {

        if( await userRole({userId : currentUserId} ) ){
            this.columns = columnsLead
        } else {
            this.columns = columns
        }
    }

    //Evento al caricamento della pagina 
    connectedCallback(){
        this.isLoading = true;
        this.chooseColumn()
        this.loadContext()
        //copiato, dovrebbe far partire l'evento del trigger item
        subscribe(this.CHANNEL_NAME, -1, this.manageEvent).then(response => {
            console.log('Subscribed Channel');
            this.subscription = response;
        });
        onError(error => {
            console.error('Server Error--->'+error);
        });
    }

    //copiato, dovrebbe gestire l'evento del triggere item e ricraricare la lista dinamicamente 
    manageEvent = event=> {
        const refreshRecordEvent = event.data.payload;
        this.isLoading = true;
        if (refreshRecordEvent.Record_Id__c === this.recordId && refreshRecordEvent.User_Id__c === currentUserId) {
            this.isFiltering = true;
            this.refresh()
            this.loadContext().then(() => {
                this.isFiltering = false;
            })
        }
        else if (refreshRecordEvent.User_Id__c === currentUserId) { 
            this.isFiltering = true; 
            this.refresh()          
            this.loadContext().then(() => {
                this.isFiltering = false;
            })

        }
    }

    //non lo so
    disconnectedCallback() {
        unsubscribe(this.subscription, response => {
        });
    }

    //Funzione che carica i dati da backand e assegna icone sulla colonna count__c
    async loadContext(){
        
        await serchItem({strItemName : this.queryTerm, 
                        userId : currentUserId, 
                        status : this.status, 
                        offsetPage : this.offset})
        .then(result => {

            this.resultQ = result
            this.finalSubType = [...this.finalSubType, ...result.map(             
            record => {

                if ( record.Count__c < record.ThresholdLimit__c && record.Count__c != 0) {

                    return  Object.assign(
                        { "SubType__r.Name": record.SubType__r.Name },
                        { "Location__r.Name": record.Location__r.LocationType },
                        { dynamicIcon : "utility:warning"},
                        record
                        )

                } else if (record.Count__c == 0) {

                    return  Object.assign(
                        { "SubType__r.Name": record.SubType__r.Name },
                        { "Location__r.Name": record.Location__r.LocationType },
                        { dynamicIcon : "utility:clear"},
                        record
                        )

                } else {    

                    return  Object.assign(
                        { "SubType__r.Name": record.SubType__r.Name },
                        { "Location__r.Name": record.Location__r.LocationType },
                        record
                        )
                }
            })]
    
            this.error = undefined
            this.isLoading = false
            this.loadMoreStatus = ''

            
            if (this.resultQ.length < this.totalNumberOfRows) { //fix quando finalSubType è multiplo di 20
                
                this.isInfEnabled = false
            }
            
            if (this.targetDatatable) this.targetDatatable.isLoading = false

        })
        .catch(error => {
            this.showToastWarning()
            this.error = error;
            this.finalSubType = undefined;
            this.isLoading = false
        });

    }

    //resetto tutte le variabili per l'infinity scroll
    refresh(){

        this.offset = 0
        this.finalSubType = []
        this.isInfEnabled = true

    }

    //toast per gli errori
    showToastWarning() {
        const event = new ShowToastEvent({
            title: 'Input error',
            variant: 'error',   
            message:this.errorMsg ,
        });
        this.dispatchEvent(event);
    }

    //toast per conferme
    showToast() {
        const event = new ShowToastEvent({
            title: 'Aggiornato correttamente',
            variant: 'success',
    
        });
        this.dispatchEvent(event);
    }

    //handler per la barra di ricerca
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13

        if (isEnterKey) {
            this.queryTerm = evt.target.value

            if(this.queryTerm == 'Simone'){
                this.errorMsg = 'Er mejo de mondo'//<---------------------------------------------------------------------------------------------------------------------------
                this.showToastWarning()
            }

            this.isFiltering = true;
            this.refresh()
            this.loadContext().then(() => {
                this.isFiltering = false;
            })
            
        }
        this.errorMsg = 'No results.'
    }

    //handelr per il pulsante degli item non in stock
    handleClearButtonClick(){

        this.clearState = !this.clearState
        this.refresh()

        if(this.clearState){
            this.status += '1'
        } else {
            this.status = this.status.replace('1','')
        }
        this.isFiltering = true;
        this.loadContext().then(() => {
            this.isFiltering = false;
        })
        this.errorMsg = 'All filter deselected.'
    }

    //handelr per il pulsante degli item in eusarimento
    handleWarningButtonClick(){

        this.warningState = !this.warningState
        this.refresh()

        if(this.warningState){
            this.status += '2'
        } else {
            this.status = this.status.replace('2','')
        }
        this.isFiltering = true;
        this.loadContext().then(() => {
            this.isFiltering = false;
        })
        this.errorMsg = 'All filter deselected.'
    }

    //handelr per il pulsante degli item in stock
    handleSuccessButtonClick(){

        this.successState = !this.successState
        this.refresh()

        if (this.successState) {
            this.status += '3'
        } else {
            this.status = this.status.replace('3','')
        }
        this.isFiltering = true;
        this.loadContext().then(() => {
            this.isFiltering = false;
        })
        this.errorMsg = 'All filter deselected.'
    }

    //handler per il pulsante 'change' sulla riga della datatable
    callRowAction( event ) {  

        this.recId = event.detail.row.Id 
        this.name = event.detail.row.Name
        this.count = event.detail.row.Count__c

        const actionName = event.detail.action.name; 

        if ( actionName === 'Change' ) { 
            this.openModal()
        }
    }


    renderedCallback(){
        console.log(this.offset);
    }

    //handelr per caricare più record
    handleLoadMore(event){
        event.preventDefault();
       
        if(this.isFiltering){
            this.offset = 0;
        } else {
            this.offset += 20
            event.target.isLoading = true;
            this.targetDatatable = event.target;
            this.loadContext() 
        }        

    }
    //handler solo per aprire il modale chiamato da callRowAction
    openModal() {
        this.isModalOpen = true
    }
    //handler solo per chiudere i modale 
    closeModal() {
        this.isModalOpen = false
        this.isButtonDisabled = false
    }
    //handler barra di ricerca, 
    //viene chiamato ogni volta che viene premuto un tasto e controlla che la quantità rimossa non superi la quantità in giacenza disabilitanto il tasto remove
    handleInputChange(event) {
        
        this.textValue = parseInt(event.detail.value);
        this.finalSubType.forEach((item) => {

            if (item.Id == this.recId) {
               
                if (item.Count__c < this.textValue) {
                    this.isButtonDisabled = true
                } else { 
                    this.isButtonDisabled = false
                }
            }
        })
        
    }
    //handelr tasto add sul modale per aggiungere la quantità su count__c chiamando apex
    Add(){
        updateCount({idItem : this.recId, n : this.textValue})
        this.closeModal()
        this.showToast() 
        this.refresh()
        this.createdRecord = true    
    }
    //handler tasto remove sul modale per rimuovere la quantità su count__c chiamando apex
    Remove(){   
        updateCount({idItem : this.recId, n : -(this.textValue)})
        this.closeModal()
        this.showToast()
        this.refresh()
        this.createdRecord = true
    }
}