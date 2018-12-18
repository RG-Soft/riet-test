
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Approval = ПолучитьСсылкуНаApproval(ПараметрКоманды);
	
	Если Approval = Неопределено Тогда
		
		Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS()  Тогда 
			Сообщить("Нет отправленных заявок на утверждение!");
		Иначе 
			Сообщить("There are no approvals for current AP invoice!");
		КонецЕсли;
		
		Возврат;
		
	КонецЕсли;
	
	ПоказатьВопрос(
		Новый ОписаниеОповещения("ОбработкаКомандыCancelApprovalЗавершение", 
		LocalDistributionForNonLawsonКлиент, Новый Структура("Approval,Trip", Approval,ПараметрКоманды)),
		?(РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS(),
		"Отменить утверждение?",
		"Cancel approval?"), 
		РежимДиалогаВопрос.ДаНет,
		60,
		КодВозвратаДиалога.Нет,
		,
		КодВозвратаДиалога.Нет);
		
КонецПроцедуры

&НаСервере
Функция ПолучитьСсылкуНаApproval(RentalCost)
	
	Возврат Задачи.RentalCostsApproval.ПолучитьСсылкуНаApproval(RentalCost);
	
КонецФункции
