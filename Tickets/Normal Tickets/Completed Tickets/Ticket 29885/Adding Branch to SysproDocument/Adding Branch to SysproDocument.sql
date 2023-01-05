USE SysproDocument;
GO

DECLARE @CopyFrom varchar(10) = '310'
DECLARE @NewBranch varchar(10) = '315'
DECLARE @NewBranchName varchar(25) = 'Annapolis'


INSERT INTO BII.Branch_SplitEligible (Branch, SplitEligible)
SELECT @NewBranch, SplitEligible 
FROM BII.Branch_SplitEligible
WHERE Branch = @CopyFrom
;

INSERT INTO ESI.Branch_SplitEligible (Branch, SplitEligible)
SELECT @NewBranch, SplitEligible 
FROM ESI.Branch_SplitEligible
WHERE Branch = @CopyFrom
;

INSERT INTO SDS.Branch_SplitEligible (Branch, SplitEligible)
SELECT @NewBranch, SplitEligible 
FROM SDS.Branch_SplitEligible
WHERE Branch = @CopyFrom
;





INSERT INTO BII.Branch_WarehouseToUse(Branch, WarehouseSource, ConstantValue)
SELECT @NewBranch, WarehouseSource, ConstantValue 
FROM BII.Branch_WarehouseToUse
WHERE Branch = @CopyFrom
;

INSERT INTO ESI.Branch_WarehouseToUse(Branch, WarehouseSource, ConstantValue)
SELECT @NewBranch, WarehouseSource, ConstantValue 
FROM ESI.Branch_WarehouseToUse
WHERE Branch = @CopyFrom
;

INSERT INTO SDS.Branch_WarehouseToUse(Branch, WarehouseSource, ConstantValue)
SELECT @NewBranch, WarehouseSource, ConstantValue 
FROM SDS.Branch_WarehouseToUse
WHERE Branch = @CopyFrom
;




INSERT INTO BIS.Discount_Branch(BranchId, DiscountCode, DiscountEnabled)
SELECT @NewBranch, DiscountCode, DiscountEnabled
FROM BIS.Discount_Branch
WHERE BranchID = @CopyFrom
;

INSERT INTO ESS.Discount_Branch(BranchId, DiscountCode, DiscountEnabled)
SELECT @NewBranch, DiscountCode, DiscountEnabled
FROM ESS.Discount_Branch
WHERE BranchID = @CopyFrom
;



