import { IContribution } from "./InstallmentReport";

export default function distributeChange(components: IContribution[], sum: number, index: number, newValue: number) {
    const lComponents = components.map((value, index) => {
        return {
            ...value,
            index: index
        };
    })

    // Create an array of objects with the value and index
    // to make it easier to work with
    if (newValue >= sum) {
        newValue = sum;
        lComponents.forEach(contribution => {
            if (contribution.index !== index) {
                contribution.value = 0;
            } else {
                contribution.value = newValue;
            }
        });
    } else {
        const oldVal = lComponents[index].value;
        const distOver = lComponents.length - 1;

        const diff = newValue - oldVal;
        const mod = diff % distOver;

        const lNewVal = newValue - mod;
        var split = (diff - mod) / distOver;

        //If one decreases, the rest split the gain

        for (var counter = 0; counter < lComponents.length; counter++) {
            const lContribution = lComponents[counter];
            if (lContribution.index !== index) {
                var cVal = lContribution.value - split;
                lContribution.value = cVal;
            } else {
                lContribution.value = lNewVal;
            }
        }
    }

    var remainder = lComponents.reduce((total, item) => {
        if (item.value < 0) {
            total += item.value;
            item.value = 0;
        }
        return total;
    }, 0);

    const applyAdjust = (negVal, element) => {
        element.value += reduceBy;
        if (element.value < 0) {
            negVal += element.value;
            element.value = 0;
        }
        return negVal;
    }

    //Reallocate from those that have gone negative
    while (remainder !== 0) {
        const toDec = lComponents.reduce((progress, element) => {
            if (index !== element.index && 0 !== element.value) {
                progress.push(element);
            }
            return progress;
        }, []);
        const modulo = remainder % toDec.length;
        //Apply the remainder to the largest element
        toDec.sort((a, b) => {
            return (b.value - a.value);
        });
        toDec[0].value += modulo;
        var reduceBy = Math.ceil((remainder - modulo) / toDec.length);


        //Apply the reductions and adjustment
        remainder = toDec.reduce(applyAdjust, 0);
    }
    return lComponents;

}

