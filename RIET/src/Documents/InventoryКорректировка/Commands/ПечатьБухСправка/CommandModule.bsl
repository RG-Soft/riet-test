
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	#Если Не ТонкийКлиент И Не ВебКлиент Тогда
	Документы.InventoryКорректировка.БухСправка(ПараметрКоманды);
	#КонецЕсли
КонецПроцедуры
