
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПоказатьВопрос(
		Новый ОписаниеОповещения("ОбработкаКомандыMultiModalCopyЗавершение", 
		LocalDistributionForNonLawsonКлиент, Новый Структура("ПараметрКоманды", ПараметрКоманды)),
		?(РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS(),
		"Копировать заявку с данными о грузовых местах?",
		"Copy transport request with parcels and items?"), 
		РежимДиалогаВопрос.ДаНет,
		60,
		КодВозвратаДиалога.Нет,
		,
		КодВозвратаДиалога.Нет);
		     		
КонецПроцедуры

