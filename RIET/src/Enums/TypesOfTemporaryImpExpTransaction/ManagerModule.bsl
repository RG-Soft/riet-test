
Функция ПолучитьImportExport(TypeOfTemporaryImpExpTransaction) Экспорт
	
	TypesOfTemporaryImpExpTransaction = Перечисления.TypesOfTemporaryImpExpTransaction;
	
	Если TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.TemporaryImport
		ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.Reexport
		ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.PermanentImport Тогда
		
		Возврат Перечисления.ИмпортЭкспорт.Import;
		
	ИначеЕсли TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.TemporaryExport
		ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.Reimport
		ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.PermanentExport Тогда
		
		Возврат Перечисления.ИмпортЭкспорт.Export;
		
	Иначе
		
		Возврат Неопределено;
		
	КонецЕсли;
	
КонецФункции

Функция ЭтоРучноеПринятие(TypeOfTemporaryImpExpTransaction) Экспорт
	
	TypesOfTemporaryImpExpTransaction = Перечисления.TypesOfTemporaryImpExpTransaction;
	
	Возврат TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.TemporaryImport
			ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.TemporaryExport;
	
КонецФункции
		
Функция ЭтоВывод(TypeOfTemporaryImpExpTransaction) Экспорт
	
	TypesOfTemporaryImpExpTransaction = Перечисления.TypesOfTemporaryImpExpTransaction;
	
	Возврат TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.Reexport
			ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.Reimport
			ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.PermanentImport
			ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.PermanentExport;
	
КонецФункции
		
Функция ПолучитьImportExportForItem(TypeOfTemporaryImpExpTransaction) Экспорт
	
	TypesOfTemporaryImpExpTransaction = Перечисления.TypesOfTemporaryImpExpTransaction;
	
	Если TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.Reexport
		ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.PermanentImport Тогда
		
		Возврат Перечисления.ИмпортЭкспорт.Import;
		
	ИначеЕсли TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.Reimport
		ИЛИ TypeOfTemporaryImpExpTransaction = TypesOfTemporaryImpExpTransaction.PermanentExport Тогда
		
		Возврат Перечисления.ИмпортЭкспорт.Export;
		
	Иначе
		
		Возврат Неопределено;
		
	КонецЕсли;
	
КонецФункции