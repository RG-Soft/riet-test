             
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПараметрыФормы = Новый Структура("Ключ", ПараметрКоманды);
	
	ОткрытьФорму("Документ.РеализацияТоваровУслуг.Форма.ФормаПечатиКС2Управляемая", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, 
										ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно);
	
КонецПроцедуры

