//
//  ripple.metal
//  AwesomeAnimation
//
//  Created by liugang zhang on 2026/2/13.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/**
 * 水波纹效果着色器
 *
 * 数学原理：
 * 1. 波的传播：水波以恒定速度从波源向外扩散，距离波源越远，波到达的时间越晚
 *    - 延迟时间 = 距离 / 传播速度
 *
 * 2. 正弦波动：使用 sin 函数产生周期性的波动
 *    - sin(frequency * time) 产生固定频率的简谐振动
 *    - frequency (角频率) 决定波的密集程度，值越大波峰越密集
 *
 * 3. 指数衰减：使用 exp(-decay * time) 使波随时间逐渐减弱
 *    - decay (衰减系数) 决定衰减速度，值越大衰减越快
 *    - 这模拟了现实中波能量随距离和时间的耗散
 *
 * 4. 位移计算：将像素沿径向方向偏移，产生视觉上的波浪效果
 *    - 偏移量 = 水波强度 × 径向单位向量
 *    - 这样保证了波沿着传播方向产生位移
 *
 * 5. 着色增强：基于水波强度增加亮度，增强立体感
 *    - 凸起的部分（正偏移）变亮，凹陷的部分保持原样
 *
 * @param position  当前像素在图层中的坐标 (inout)
 * @param layer     SwiftUI 图层对象，提供纹理采样功能
 * @param origin    水波纹的起始点（波源坐标）
 * @param time      动画当前时间（秒），从动画开始时计时
 * @param amplitude 水波的最大振幅（像素），决定波的强度和可见程度
 * @param frequency 波动频率，决定波的密集程度（弧度/秒）
 * @param decay     衰减系数，决定波消失的速度
 * @param speed     波的传播速度（像素/秒），控制波向外扩散的快慢
 * @return          采样后的颜色值，带有水波效果
 */
[[ stitchable ]]
half4 Ripple(float2 position,
             SwiftUI::Layer layer,
             float2 origin,
             float time,
             float amplitude,
             float frequency,
             float decay, float speed) {

    // 计算当前像素到波源的距离
    // 原理：勾股定理 distance = sqrt((x2-x1)² + (y2-y1)²)
    // Metal 提供了 length() 函数直接计算向量长度
    float distance = length(position - origin);

    // 计算波传播到该像素所需的时间延迟
    // 原理：时间 = 距离 / 速度（匀速运动公式 t = s/v）
    // 距离波源越远的位置，延迟越大，波越晚到达
    float delay = distance / speed;

    // 有效时间 = 当前时间 - 传播延迟
    // 如果时间小于等于0，说明波还没传播到这里，该位置还不会产生波动
    time -= delay;

    // 确保时间不为负
    // max(time, 0.0) 使得波前（wave front）之前的位置不产生波动
    // 波前是指当前时刻波刚传播到的位置
    time = max(time, 0.0);

    // 计算当前像素的水波偏移量
    // 公式：offset = A * sin(ωt) * e^(-kt)
    // 其中：
    //   - A (amplitude): 振幅，控制波的最大位移
    //   - sin(ωt): 正弦波动，ω = 2πf 为角频率
    //   - e^(-kt): 指数衰减，k = decay 控制衰减速度
    //
    // 这个公式产生的是一个振幅随时间指数衰减的正弦波
    // 模拟了现实中水波从中心向外扩散并逐渐减弱的过程
    float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);

    // 计算径向单位向量（从波源指向当前像素的方向向量）
    // 原理：将向量除以其长度，得到单位向量（长度为1，方向不变）
    // normalize() = vector / length(vector)
    float2 n = normalize(position - origin);

    // 计算像素的新位置（用于纹理采样）
    // 原理：沿波的传播方向偏移像素
    // 新位置 = 原位置 + 偏移量 × 方向向量
    // 这样采样时会产生视觉上的波浪扭曲效果
    float2 newPosition = position + rippleAmount * n;

    // 从图层中采样新位置的颜色
    // 使用双线性插值进行采样，得到平滑的效果
    half4 color = layer.sample(newPosition);

    // 基于水波强度增强颜色亮度
    // 原理：rippleAmount / amplitude 将偏移量归一化到 [-1, 1]
    //       正值表示波峰（凸起），负值表示波谷（凹陷）
    //       波峰部分增加 30% 的亮度，增强立体感和高光效果
    //       0.3 是经验系数，控制高光的强度
    color.rgb += 0.3 * (rippleAmount / amplitude) * color.a;

    return color;
}
