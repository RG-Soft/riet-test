
Функция ПолучитьПредставлениеLoadingTypeRU(LoadingType) Экспорт
	
	LoadingTypes = Перечисления.LoadingTypes;
	Если LoadingType = LoadingTypes.Back Тогда 
		Возврат "задняя";
	ИначеЕсли LoadingType = LoadingTypes.FullRastentovka Тогда 
		Возврат "полная растентовка";
	ИначеЕсли LoadingType = LoadingTypes.Side Тогда 
		Возврат "боковая";
	ИначеЕсли LoadingType = LoadingTypes.Top Тогда 
		Возврат "верхняя";
	Иначе 
		Возврат "";
	КонецЕсли;
	
КонецФункции