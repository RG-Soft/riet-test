Перем ПрошлыйИзмененныйРодительОбъектаДоступа;

Процедура ПередЗаписью(Отказ)
	      	
	Перем мСсылкаНового;
	
	Если НЕ ОбменДанными.Загрузка Тогда
				
		ПрошлыйИзмененныйРодительОбъектаДоступа = ?(Не ЭтоНовый() и Не Ссылка.Родитель = Родитель, Ссылка.Родитель, Неопределено);
		Если ЗначениеЗаполнено(мСсылкаНового) Тогда
			НастройкаПравДоступа.ПередЗаписьюНовогоОбъектаСПравамиДоступаПользователей(ЭтотОбъект, Отказ, Родитель, мСсылкаНового);
		КонецЕсли; 
		
	КонецЕсли;
       			
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если НЕ ОбменДанными.Загрузка Тогда
				
		НастройкаПравДоступа.ОбновитьПраваДоступаКИерархическимОбъектамПриНеобходимости(Ссылка,ПрошлыйИзмененныйРодительОбъектаДоступа, Отказ);
		
	КонецЕсли;
	
	ОбновитьLegalEntityВAUsПриНеобходимости();
		
КонецПроцедуры

Процедура ОбновитьLegalEntityВAUsПриНеобходимости()
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("TaxRegistration", Ссылка);

	Запрос.Текст = "ВЫБРАТЬ
	|	КостЦентры.Ссылка КАК AU
	|ИЗ
	|	Справочник.КостЦентры КАК КостЦентры
	|ГДЕ
	|	КостЦентры.TaxRegistration = &TaxRegistration
	|	И НЕ КостЦентры.ПометкаУдаления";
		
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		РегистрыСведений.AUsAndLegalEntities.ДобавитьОбновитьЗаписьAUsAndLegalEntities(Выборка.AU, LegalEntity, НачалоМесяца(ТекущаяДата()));
		
	КонецЦикла;
	
КонецПроцедуры
