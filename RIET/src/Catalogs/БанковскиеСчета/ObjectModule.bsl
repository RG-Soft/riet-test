
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	#Если Клиент тогда
		Если ОбщегоНазначения.ЕстьНеЦифры(НомерСчета) И Вопрос("В составе номера банковского счета присутствуют не только цифры. 
			|Возможно, номер указан неправильно. Записать?",РежимДиалогаВопрос.ДаНет)=КодВозвратаДиалога.Нет Тогда
			
			Отказ=Истина;
			
		КонецЕсли;
	#КонецЕсли
	
КонецПроцедуры
     
